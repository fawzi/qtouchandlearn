/*
    Touch'n'learn - Fun and easy mobile lessons for kids
    Copyright (C) 2010, 2011 by Alessandro Portale
    http://touchandlearn.sourceforge.net

    This file is part of Touch'n'learn

    Touch'n'learn is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Touch'n'learn is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Touch'n'learn; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
*/

import QtQuick 2.1
import "database.js" as Database

Item {
    property alias backgroundImage: backgroundImage.source
    property alias currentExerciseIndex: listview.currentIndex
    property bool grayBackground
    property string exerciseFunction
    property int answersCount
    property real imageSizeFactor: 0.61

    property int backgroundImageSourceSizeHeight: height * 0.3
    property int backgroundImageSourceSizeWidth: backgroundImageSourceSizeHeight * 6.0
    property int backgroundWhiteRectHeight: (height - backgroundImageSourceSizeHeight) * 0.65
    property int backgroundBlackRectHeight: height - backgroundWhiteRectHeight - backgroundImageSourceSizeHeight
    property int imageSourceSizeWidthHeight: (height < width ? height : width) * imageSizeFactor

    function goForward() {
        listview.incrementCurrentIndex();
    }
    id: imageview
    Rectangle {
        property int _hueSpanInPixels: imageview.width * 10;
        property int hueOffset: Math.random() * _hueSpanInPixels
        anchors.fill: parent
        color: grayBackground ? "#E0E0E0"
                              : Qt.hsla(((listview.contentX + hueOffset) % _hueSpanInPixels) / _hueSpanInPixels, 0.4, 0.8, 1);
    }

    Item {
        Rectangle {
            id: white
            height: backgroundWhiteRectHeight
            width: imageview.width
            color: "#fff"
        }
        Image {
            property int _width: (Math.ceil(imageview.width / backgroundImageSourceSizeWidth) + 1) * backgroundImageSourceSizeWidth * devicePixelRatio
            fillMode: Image.Tile
            id: backgroundImage
            sourceSize { height: backgroundImageSourceSizeHeight * devicePixelRatio; width: backgroundImageSourceSizeWidth * devicePixelRatio}
            width: _width
            x: ((-listview.contentX - 10 * imageview.width) * 0.3) % backgroundImageSourceSizeWidth
            y: backgroundWhiteRectHeight
            scale: devicePixelRatioScale
            transformOrigin: Item.TopLeft
        }
        Rectangle {
            y: backgroundImage.height * devicePixelRatioScale + backgroundWhiteRectHeight
            height: backgroundBlackRectHeight
            width: imageview.width
            color: "#000"
        }
        opacity: 0.08
    }

    ListView {
        id: listview
        anchors.fill: parent
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.DragOverBounds
        highlightRangeMode: ListView.StrictlyEnforceRange
        maximumFlickVelocity: width / 2
        highlightMoveDuration: 1000
        model: 100000

        delegate: Item {
            id: delegate
            width: listview.width // Must not be parent.height/width since those are 0 in the beginning
            height: listview.height
            Image {
                // Hand-centered in order to avoid non-integer image coordinates.
                property int _leftMargin: (delegate.width - width / devicePixelRatio) / 2
                property int _topMargin: (delegate.height - height / devicePixelRatio) / 2
                anchors { left: parent.left; top: parent.top; leftMargin: _leftMargin; topMargin: _topMargin; }
                source: Database.exercise(modelData, exerciseFunction, answersCount).ImageSource
                sourceSize { width: imageSourceSizeWidthHeight * devicePixelRatio; height: imageSourceSizeWidthHeight * devicePixelRatio }
                asynchronous: true
                scale: devicePixelRatioScale
                transformOrigin: Item.TopLeft
            }
        }
    }

    Image {
        sourceSize { height: parent.height * devicePixelRatio; width: parent.width * devicePixelRatio }
        source: "image://imageprovider/frame/0"
        smooth: false
        scale: devicePixelRatioScale
        transformOrigin: Item.TopLeft
    }
}
