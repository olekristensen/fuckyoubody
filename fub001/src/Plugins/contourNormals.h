#pragma once

#include "ofxVectorMath.h"
#include "ofxOpenCv.h"

#include "ofMain.h"

class contourNormals{

	public:
		contourNormals(){

		}

		//------------------------------
		void makeNormals(vector <ofxVec2f> &contourIn, vector <ofxVec2f> &normalsOut, int direction = 1){
			int length = contourIn.size();

			normalsOut.clear();
			normalsOut.assign(length, ofxVec2f() );

			ofxVec2f normal;
			ofxVec2f delta;
			for(int i = 1; i < length; i++){
                delta = contourIn[i] - contourIn[i-1];
                delta.normalize();

                if(direction){
                    normal.set(delta.y, -delta.x);
                }else{
                    normal.set(-delta.y, delta.x);
                }

                normalsOut[i] = normal;
			}

		}


};
