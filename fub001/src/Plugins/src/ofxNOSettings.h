#ifndef _OFX_IIDC_SETTINGS_H
#define _OFX_IIDC_SETTINGS_H

#include "ofxVideoGrabberSettings.h"

class ofxVideoGrabberSDK;

class ofxNOSettings :  public ofxVideoGrabberSettings
{
    public:
        ofxNOSettings();
        virtual ~ofxNOSettings();

        virtual void setupGUI();
        virtual void update();
        virtual void draw();

    protected:
        void parameterCallback(float param1, float param2, int param_mode, int callback_id);
//        ParameterCallback<ofxNOSettings> callback;


};

#endif
