/********************************************************************************
** Form generated from reading UI file 'save.ui'
**
** Created by: Qt User Interface Compiler version 5.9.3
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_SAVE_H
#define UI_SAVE_H

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

class Ui_SaveClass
{
public:
    QMenuBar *menuBar;
    QToolBar *mainToolBar;
    QWidget *centralWidget;
    QStatusBar *statusBar;

    void setupUi(QMainWindow *SaveClass)
    {
        if (SaveClass->objectName().isEmpty())
            SaveClass->setObjectName(QStringLiteral("SaveClass"));
        SaveClass->resize(600, 400);
        menuBar = new QMenuBar(SaveClass);
        menuBar->setObjectName(QStringLiteral("menuBar"));
        SaveClass->setMenuBar(menuBar);
        mainToolBar = new QToolBar(SaveClass);
        mainToolBar->setObjectName(QStringLiteral("mainToolBar"));
        SaveClass->addToolBar(mainToolBar);
        centralWidget = new QWidget(SaveClass);
        centralWidget->setObjectName(QStringLiteral("centralWidget"));
        SaveClass->setCentralWidget(centralWidget);
        statusBar = new QStatusBar(SaveClass);
        statusBar->setObjectName(QStringLiteral("statusBar"));
        SaveClass->setStatusBar(statusBar);

        retranslateUi(SaveClass);

        QMetaObject::connectSlotsByName(SaveClass);
    } // setupUi

    void retranslateUi(QMainWindow *SaveClass)
    {
        SaveClass->setWindowTitle(QApplication::translate("SaveClass", "Save", Q_NULLPTR));
    } // retranslateUi

};

namespace Ui {
    class SaveClass: public Ui_SaveClass {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_SAVE_H
