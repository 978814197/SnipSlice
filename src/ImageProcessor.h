#ifndef IMAGEPROCESSOR_H
#define IMAGEPROCESSOR_H

#include <QObject>
#include <QQmlEngine>
#include <QImage>
#include <QString>
#include <QUrl>

class ImageProcessor : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit ImageProcessor(QObject *parent = nullptr);

    // 裁剪并保存图片
    Q_INVOKABLE bool cropAndSave(const QUrl &sourceUrl,
                                   const QUrl &targetUrl,
                                   qreal x,
                                   qreal y,
                                   qreal width,
                                   qreal height);

private:
    // 从URL加载图片
    QImage loadImage(const QUrl &url);

    // 保存图片
    bool saveImage(const QImage &image, const QUrl &url);

    // 获取文件格式
    QString getImageFormat(const QString &filePath);
};

#endif // IMAGEPROCESSOR_H
