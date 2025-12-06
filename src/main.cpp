#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QTranslator>
#include <QLocale>

int main(int argc, char* argv[])
{
    const QGuiApplication app(argc, argv);

    QTranslator translator;
    if (translator.load(QLocale(), "SnipSlic", "_", ":/i18n"))
    {
        QGuiApplication::installTranslator(&translator);
    }

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("ui", "Main");

    return QGuiApplication::exec();
}
