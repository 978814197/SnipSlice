#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QTranslator>
#include <QLocale>
#include "ImageProcessor.h"

int main(int argc, char* argv[])
{
    const QGuiApplication app(argc, argv);

    QTranslator translator;
    if (translator.load(QLocale(), "SnipSlic", "_", ":/i18n"))
    {
        QGuiApplication::installTranslator(&translator);
    }

    // 创建ImageProcessor单例实例
    ImageProcessor imageProcessor;

    QQmlApplicationEngine engine;

    // 将ImageProcessor暴露给QML
    engine.rootContext()->setContextProperty("ImageProcessor", &imageProcessor);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("ui", "Main");

    return QGuiApplication::exec();
}
