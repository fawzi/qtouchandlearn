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
import QtQuick.Particles 2.0

Item {
    property int index: 0
    property string text
    property string correctionImageSource
    property bool isCorrectAnswer: false
    property bool grayBackground: false
    property color normalStateColor: "#fff"
    property color correctStateColor: "#ffa"
    property color wrongStateColor: "#f66"
    property color correctionStateColor: grayBackground ? "#ccc" : "#fbb"

    property int wrongAnswerShakeAmplitudeCalc: width * 0.2
    property int wrongAnswerShakeAmplitudeMin: 45
    property int wrongAnswerShakeAmplitude: wrongAnswerShakeAmplitudeCalc < wrongAnswerShakeAmplitudeMin ? wrongAnswerShakeAmplitudeMin : wrongAnswerShakeAmplitudeCalc
    property int correctionImageSize: (height < width ? height : width) * 0.9 * devicePixelRatio

    signal correctlyPressed
    signal incorrectlyPressed
    signal contentChangeAnimationFinished

    id: button
    Rectangle {
        id: rect
        anchors.fill: parent
        color: normalStateColor
    }
    ParticleSystem {
        id: particleSystem
        running: Qt.application.state === Qt.ApplicationActive
    }
    ImageParticle {
        anchors.fill: parent
        system: particleSystem
        rotationVelocity: 50
        rotationVelocityVariation: 20
        source: "../../data/graphics/particle.png"
        clip: true
    }
    Emitter {
        property int _size: (height < width ? height : width) / 2.0
        property int _sizeVariation: _size * 0.1
        anchors.fill: parent
        id: particles
        system: particleSystem
        lifeSpan: 700
        lifeSpanVariation: 150
        velocity: AngleDirection {
            property int _velocityMagnitude: (height < width ? height : width) / 2.0
            magnitude: _velocityMagnitude;
            angleVariation: 360
        }
        size: _size
        sizeVariation: _sizeVariation
        enabled: false
        emitRate: 50
    }
    Image {
        source: "image://imageprovider/button/" + index
        sourceSize { height: parent.height * devicePixelRatio; width: parent.width * devicePixelRatio }
        width: sourceSize.width
        height: sourceSize.height
        smooth: false
        scale: devicePixelRatioScale
        transformOrigin: Item.TopLeft
    }
    Text {
        id: label
        anchors.verticalCenter: parent.verticalCenter
        // We need to manually horizonally center the text, because in wrongAnswerAnimation,
        // the x of the text is changed, which would not work if we use an anchor layout.
        property int horizontallyCenteredX: (button.width - width) >> 1;
        x: horizontallyCenteredX;
        font.pixelSize: parent.height * 0.33
    }
    Image {
        id: correctionImage
        // Hand-centered in order to avoid non-integer image coordinates.
        property int _leftMargin: (parent.width - width / devicePixelRatio) / 2
        property int _topMargin: (parent.height - height / devicePixelRatio) / 2
        sourceSize { width: correctionImageSize * devicePixelRatio; height: correctionImageSize * devicePixelRatio }
        anchors { left: parent.left; top: parent.top; leftMargin: _leftMargin; topMargin: _topMargin; }
        opacity: 0
        smooth: false
        scale: devicePixelRatioScale
        transformOrigin: Item.TopLeft
    }

    MouseArea {
        anchors.fill: parent
        onPressed: {
            if (!blockClicks) {
                if (isCorrectAnswer)
                    correctAnswerAnimation.start();
                else
                    wrongAnswerAnimation.start();
            }
        }
    }

    onTextChanged: {
        if (wrongAnswerAnimation.running) {
            wrongAnswerAnimation.stop();
            label.opacity = 1;
            correctionImage.opacity = 0;
            rect.color = normalStateColor;
        }
        if (correctAnswerAnimation.running) {
            correctAnswerAnimation.stop();
            rect.color = normalStateColor;
        }

        if (label.text.length === 0) {
            label.text = text;
        } else {
            contentChangeAnimation.complete();
            contentChangeAnimation.start();
        }
    }

    SequentialAnimation {
        id: contentChangeAnimation
        ScriptAction {
            script: blockClicks = true
        }
        PauseAnimation {
            duration: 250 + index * 85
        }
        ParallelAnimation {
            PropertyAnimation {
                property: "scale"
                target: label
                from: 1
                to: 0
                easing.type: Easing.InQuad
            }
            PropertyAnimation {
                property: "opacity"
                target: label
                from: 1
                to: 0
                easing.type: Easing.InQuad
            }
        }
        PauseAnimation {
            duration: 350 + index * 70
        }
        ScriptAction { // PropertyAction would fail here, and set the prior text
            script: label.text = text
        }
        ParallelAnimation {
            PropertyAnimation {
                property: "scale"
                target: label
                from: 0
                to: 1
                easing.type: Easing.OutBack
            }
            PropertyAnimation {
                property: "opacity"
                target: label
                from: 0
                to: 1
                easing.type: Easing.OutBack
            }
        }
        ScriptAction {
            script: {
                blockClicks = false;
                contentChangeAnimationFinished();
            }
        }
    }
    SequentialAnimation {
        id: correctAnswerAnimation
        ScriptAction {
            script: {
                if (typeof(feedback) === "object")
                    feedback.playCorrectSound();
                blockClicks = true;
                particles.enabled = true;
                particles.burst(20);
                particles.enabled = false;
            }
        }
        PropertyAction {
            target: rect
            property: "color"
            value: correctStateColor
        }
        PropertyAnimation {
            property: "color"
            target: rect
            to: normalStateColor
            duration: 700
        }
        PauseAnimation {
            duration: 300 // Wait for particles to finish
        }
        ScriptAction {
            script: {
                blockClicks = false;
                correctlyPressed();
            }
        }
    }
    SequentialAnimation {
        id: wrongAnswerAnimation
        ParallelAnimation {
            SequentialAnimation {
                PropertyAction {
                    target: rect
                    property: "color"
                    value: wrongStateColor
                }
                ScriptAction {
                    script: {
                        if (typeof(feedback) === "object")
                            feedback.playIncorrectSound();
                        if (correctionImageSource.length) {
                            correctionImage.sourceSize.height = correctionImageSize
                            correctionImage.sourceSize.width = correctionImageSize
                            correctionImage.source = correctionImageSource
                        }
                    }
                }
                PropertyAnimation {
                    property: "color"
                    target: rect
                    to: correctionImageSource.length ? correctionStateColor : normalStateColor
                    duration: correctionImageSource.length ? 450 : 600
                }
            }
            SequentialAnimation {
                PropertyAnimation {
                    property: "x"
                    target: label
                    from: label.horizontallyCenteredX
                    to: label.horizontallyCenteredX - wrongAnswerShakeAmplitude
                    easing.type: Easing.InCubic
                    duration: 120
                }
                PropertyAnimation {
                    property: "x"
                    target: label
                    from: label.horizontallyCenteredX - wrongAnswerShakeAmplitude
                    to: label.horizontallyCenteredX + wrongAnswerShakeAmplitude
                    easing.type: Easing.InOutCubic
                    duration: 220
                }
                PropertyAnimation {
                    property: "x"
                    target: label
                    from: label.horizontallyCenteredX + wrongAnswerShakeAmplitude
                    to: label.horizontallyCenteredX
                    easing { type: Easing.OutBack; overshoot: 3 }
                    duration: 180
                }
            }
        }
        ParallelAnimation {
            PropertyAnimation {
                property: "opacity"
                target: correctionImageSource.length ? correctionImage : null
                from: 0
                to: 1
            }
            PropertyAnimation {
                property: "opacity"
                target: correctionImageSource.length ? label : null
                from: 1
                to: 0
            }
        }
        PauseAnimation {
            duration: correctionImageSource.length ? 1400 : 0
        }
        ParallelAnimation {
            PropertyAnimation {
                property: "opacity"
                target: correctionImageSource.length ? correctionImage : null
                from: 1
                to: 0
            }
            PropertyAnimation {
                property: "opacity"
                target: correctionImageSource.length ? label : null
                from: 0
                to: 1
            }
        }
        PropertyAnimation {
            property: "color"
            target: rect
            to: normalStateColor
            duration: 450
        }
        ScriptAction {
            script: {
                correctionImage.source = "";
                incorrectlyPressed();
            }
        }
    }
}
