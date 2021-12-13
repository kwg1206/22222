#include "savedark.h"
#include <QtWidgets/QApplication>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    SaveDark w;
    w.show();
    return a.exec();
}
