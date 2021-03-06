# Touch'n'learn - Fun and easy mobile lessons for kids
# Copyright (C) 2010, 2011 by Alessandro Portale
# http://touchandlearn.sourceforge.net
#
# This file is part of Touch'n'learn
#
# Touch'n'learn is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Touch'n'learn is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Touch'n'learn; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA

android {
    ANDROID_DEPLOYMENT_DEPENDENCIES = \
        jar/QtAndroid-bundled.jar \
        jar/QtAndroidAccessibility-bundled.jar \
        jar/QtMultimedia-bundled.jar \
        lib/libQt5Core.so \
        lib/libQt5Gui.so \
        lib/libQt5Network.so \
        lib/libQt5Qml.so \
        lib/libQt5Quick.so \
        lib/libQt5QuickParticles.so \
        lib/libQt5Multimedia.so \
        lib/libQt5MultimediaQuick_p.so \
        plugins/audio/libqtaudio_opensles.so \
        qml/QtQuick/Particles.2/qmldir \
        qml/QtQuick/Particles.2/libparticlesplugin.so \
        qml/QtQuick/Window.2/qmldir \
        qml/QtQuick/Window.2/libwindowplugin.so \
        qml/QtQuick.2/qmldir \
        qml/QtQuick.2/libqtquick2plugin.so \
        qml/QtMultimedia/libdeclarative_multimedia.so \
        qml/QtMultimedia/qmldir

    exists($$[QT_INSTALL_PREFIX]/lib/libQt5Widgets.so):ANDROID_DEPLOYMENT_DEPENDENCIES += lib/libQt5Widgets.so
    exists($$[QT_INSTALL_PREFIX]/plugins/platforms/android/libqtforandroidGL.so) {
        # Qt < 5.3
        ANDROID_DEPLOYMENT_DEPENDENCIES += /plugins/platforms/android/libqtforandroidGL.so
    } else {
        # Qt >= 5.3
        ANDROID_DEPLOYMENT_DEPENDENCIES += /plugins/platforms/android/libqtforandroid.so
    }
    ANDROID_DEPLOYMENT_DEPENDENCIES += lib/libQt5Svg.so

    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

    OTHER_FILES += \
        android/AndroidManifest.xml
}

QTPLUGIN.imageformats = -
QTPLUGIN.iconengines = -
QTPLUGIN.position = -
ios {
  QMAKE_INFO_PLIST = Info_ios.plist

  iosIcon.files = ios/AppIcon29x29.png ios/AppIcon40x40@2x.png ios/AppIcon50x50~ipad.png ios/AppIcon72x72@2x~ipad.png \
   ios/AppIcon29x29@2x.png ios/AppIcon40x40@2x~ipad.png ios/AppIcon57x57.png ios/AppIcon72x72~ipad.png \
   ios/AppIcon29x29@2x~ipad.png ios/AppIcon40x40~ipad.png ios/AppIcon57x57@2x.png ios/AppIcon76x76@2x~ipad.png \
   ios/AppIcon29x29~ipad.png ios/AppIcon50x50@2x~ipad.png ios/AppIcon60x60@2x.png ios/AppIcon76x76~ipad.png
  QMAKE_BUNDLE_DATA += iosIcon
}

RESOURCES = \
    audio.qrc \
    graphics.qrc \
    qml.qrc \
    translations.qrc

DEFINES += \
    QT_USE_FAST_CONCATENATION \
    QT_USE_FAST_OPERATOR_PLUS

VERSION = 1.1

macx:ICON = touchandlearn.icns

SOURCES += \
    main.cpp \
    imageprovider.cpp \
    settings.cpp

HEADERS += \
    imageprovider.h \
    settings.h

QT += multimedia svg qml quick


# Default rules for deployment.
include(deployment.pri)
