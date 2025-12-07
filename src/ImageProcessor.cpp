#include "ImageProcessor.h"
#include <QImageReader>
#include <QImageWriter>
#include <QFileInfo>
#include <QDebug>

ImageProcessor::ImageProcessor(QObject *parent)
    : QObject(parent)
{
}

bool ImageProcessor::cropAndSave(const QUrl &sourceUrl,
                                   const QUrl &targetUrl,
                                   qreal x,
                                   qreal y,
                                   qreal width,
                                   qreal height)
{
    // 加载源图片
    QImage sourceImage = loadImage(sourceUrl);
    if (sourceImage.isNull()) {
        qWarning() << "Failed to load source image:" << sourceUrl.toString();
        return false;
    }

    // 验证裁剪区域
    if (x < 0 || y < 0 || width <= 0 || height <= 0) {
        qWarning() << "Invalid crop region:" << x << y << width << height;
        return false;
    }

    // 确保裁剪区域不超出图片边界
    int cropX = qMax(0, static_cast<int>(x));
    int cropY = qMax(0, static_cast<int>(y));
    int cropWidth = qMin(static_cast<int>(width), sourceImage.width() - cropX);
    int cropHeight = qMin(static_cast<int>(height), sourceImage.height() - cropY);

    if (cropWidth <= 0 || cropHeight <= 0) {
        qWarning() << "Crop region out of bounds";
        return false;
    }

    // 裁剪图片
    QImage croppedImage = sourceImage.copy(cropX, cropY, cropWidth, cropHeight);

    if (croppedImage.isNull()) {
        qWarning() << "Failed to crop image";
        return false;
    }

    // 保存图片
    if (!saveImage(croppedImage, targetUrl)) {
        qWarning() << "Failed to save cropped image to:" << targetUrl.toString();
        return false;
    }

    qDebug() << "Successfully cropped and saved image to:" << targetUrl.toString();
    return true;
}

QImage ImageProcessor::loadImage(const QUrl &url)
{
    QString filePath = url.toLocalFile();
    if (filePath.isEmpty()) {
        filePath = url.toString();
        // 移除 "file:///" 前缀
        if (filePath.startsWith("file:///")) {
            filePath = filePath.mid(8);
        }
    }

    QImageReader reader(filePath);
    reader.setAutoTransform(true);  // 自动处理EXIF旋转信息

    QImage image = reader.read();
    if (image.isNull()) {
        qWarning() << "Failed to load image:" << filePath;
        qWarning() << "Error:" << reader.errorString();
    }

    return image;
}

bool ImageProcessor::saveImage(const QImage &image, const QUrl &url)
{
    QString filePath = url.toLocalFile();
    if (filePath.isEmpty()) {
        filePath = url.toString();
        // 移除 "file:///" 前缀
        if (filePath.startsWith("file:///")) {
            filePath = filePath.mid(8);
        }
    }

    // 获取图片格式
    QString format = getImageFormat(filePath);

    QImageWriter writer(filePath, format.toUtf8());
    writer.setQuality(95);  // 设置质量为95%

    if (!writer.write(image)) {
        qWarning() << "Failed to write image:" << filePath;
        qWarning() << "Error:" << writer.errorString();
        return false;
    }

    return true;
}

QString ImageProcessor::getImageFormat(const QString &filePath)
{
    QFileInfo fileInfo(filePath);
    QString suffix = fileInfo.suffix().toLower();

    // 映射文件扩展名到图片格式
    if (suffix == "jpg" || suffix == "jpeg") {
        return "JPEG";
    } else if (suffix == "png") {
        return "PNG";
    } else if (suffix == "bmp") {
        return "BMP";
    } else if (suffix == "gif") {
        return "GIF";
    }

    // 默认使用PNG格式
    return "PNG";
}
