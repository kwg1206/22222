/********************************************************************************
** Form generated from reading UI file 'savedark.ui'
**
** Created by: Qt User Interface Compiler version 5.9.3
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_SAVEDARK_H
#define UI_SAVEDARK_H

#include <QtCore/QVariant>
#include <QtWidgets/QAction>
#include <QtWidgets/QApplication>
#include <QtWidgets/QButtonGroup>
#include <QtWidgets/QHeaderView>
#include <QtWidgets/QMainWindow>
#include <QtWidgets/QMenuBar>
#include <QtWidgets/QStatusBar>
#include <QtWidgets/QToolBar>
#include <QtWidgets/QWidget>

QT_BEGIN_NAMESPACE

class Ui_SaveDarkClass
{
public:
    QMenuBar *menuBar;
    QToolBar *mainToolBar;
    QWidget *centralWidget;
    QStatusBar *statusBar;

    void setupUi(QMainWindow *SaveDarkClass)
    {
        if (SaveDarkClass->objectName().isEmpty())
            SaveDarkClass->setObjectName(QStringLiteral("SaveDarkClass"));
        SaveDarkClass->resize(600, 400);
        menuBar = new QMenuBar(SaveDarkClass);
        menuBar->setObjectName(QStringLiteral("menuBar"));
        SaveDarkClass->setMenuBar(menuBar);
        mainToolBar = new QToolBar(SaveDarkClass);
        mainToolBar->setObjectName(QStringLiteral("mainToolBar"));
        SaveDarkClass->addToolBar(mainToolBar);
        centralWidget = new QWidget(SaveDarkClass);
        centralWidget->setObjectName(QStringLiteral("centralWidget"));
        SaveDarkClass->setCentralWidget(centralWidget);
        statusBar = new QStatusBar(SaveDarkClass);
        statusBar->setObjectName(QStringLiteral("statusBar"));
        SaveDarkClass->setStatusBar(statusBar);

        retranslateUi(SaveDarkClass);

        QMetaObject::connectSlotsByName(SaveDarkClass);
    } // setupUi

    void retranslateUi(QMainWindow *SaveDarkClass)
    {
        SaveDarkClass->setWindowTitle(QApplication::translate("SaveDarkClass", "SaveDark", Q_NULLPTR));
    } // retranslateUi

};

namespace Ui {
    class SaveDarkClass: public Ui_SaveDarkClass {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_SAVEDARK_H
