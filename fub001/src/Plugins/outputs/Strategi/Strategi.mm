#include "ProjectionSurfaces.h"
#include "Tracking.h"
#include "Strategi.h"
#include "DMXOutput.h"

@implementation StrategiBlob

-(id) init{
	if([super init]){
		aliveCounter = 0;
	}
	return self;
}

@end



@implementation Strategi

-(void) setup{
	texture = new ofImage;
	texture->loadImage("waterRingTexture1.png");
	
	for(int i=0;i<2;i++){
		blobs = [[NSMutableArray array] retain];
		contourFinder[i] = new ofxCvContourFinder();
		
		images[i] = new ofxCvGrayscaleImage();
		images[i]->allocate(StrategiW, StrategiH);
		images[i]->set(0);
	}
	
	
	blur = new shaderBlur();
	blur->setup(StrategiW, StrategiH);

}


-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	if([pause state] != NSOnState){
		BOOL flagChanged = NO;
		for(int u=0;u< [blobs count]; u++){
			StrategiBlob * sblob = [blobs objectAtIndex:u];
			sblob->aliveCounter ++;
			if(sblob->aliveCounter > 20){
				[blobs removeObject:sblob];
			}
		}
		
		PersistentBlob * pblob;
		for(pblob in [tracker(0) persistentBlobs]){
			int player = -1;
			int otherPlayer;
			StrategiBlob * sblob;
			for(sblob in blobs){
				if(sblob->pid == pblob->pid){
					sblob->aliveCounter = 0;
					player = sblob->player;
					break;
				}
			}				
			if(player == -1){
				int otherPlayer = 0;
				int otherPlayerRate = 20;
				StrategiBlob * sblob;
				for(sblob in blobs){
					//	if(otherPlayer == -1 || otherPlayerRate  > sblob->aliveCounter){
					otherPlayer = 0;
					if(sblob->player == 0)
						otherPlayer = 1;
					
					otherPlayerRate = sblob->aliveCounter;
					//	}
				}	
				//				cout<<otherPlayer<<endl;
				sblob = [[StrategiBlob alloc] init]; 
				sblob->pid = pblob->pid;
				ofxPoint2f p = [pblob getLowestPoint]; //*pblob->centroid;
				ofxPoint2f centroid = [GetPlugin(ProjectionSurfaces) convertFromProjection:p surface:[GetPlugin(ProjectionSurfaces) getProjectionSurfaceByName:"Front" surface:"Floor" ]];
				//			cout<<centroid.x<<"  "<<centroid.y<<endl;
				/*if(centroid.x > 0.5){
				 player = sblob->player = 1;
				 } else {
				 player = sblob->player = 0;	
				 }*/
				player = sblob->player = otherPlayer;
				[blobs addObject:sblob];
			}
			
			if(player == 0) otherPlayer = 1;
			else otherPlayer = 0;
			
			Blob * b;
			for(b in [pblob blobs]){
				CvPoint * pointArray = new CvPoint[ [b nPts] ];
				
				for( int u = 0; u < [b nPts]; u++){
					ofxPoint2f p = [GetPlugin(ProjectionSurfaces) convertPoint:[b pts][u] fromProjection:"Front" toSurface:"Floor"];
					pointArray[u].x = int(p.x*StrategiW);
					pointArray[u].y = int(p.y*StrategiH);
					//				cout<<pointArray[u].x<<"  "<<pointArray[u].y<<endl;
				}
				int nPts = [b nPts];
				cvFillPoly(images[player]->getCvImage(),&pointArray , &nPts, 1, cvScalar(255.0, 255.0, 255.0, 255.0));			
				*images[otherPlayer] -= *images[player];
				flagChanged = YES;
				images[player]->flagImageChanged();
				
			}
		}
		
		if([blurSlider floatValue] > 0){
			for(int i=0;i<2;i++){
				images[i]->blur([blurSlider intValue]);
			}
		}
		
		if(flagChanged){
			for(int u=0;u<2;u++){
				ofxCvGrayscaleImage smallerImage;
				smallerImage.allocate(StrategiBlobW, StrategiBlobH);
				smallerImage.scaleIntoMe(*images[u], CV_INTER_NN);
				contourFinder[u]->findContours(smallerImage, 20, (StrategiBlobW*StrategiBlobH)/1, 10, false, true);	
				area[u] = 0;
				for(int j=0;j<contourFinder[u]->nBlobs;j++){
					area[u] += contourFinder[u]->blobs[j].area;
				}
				//	cout<<u<<": "<<area[u]<<endl;
				
			}
		}
		
		if([fade floatValue]){
			for(int i=0;i<2;i++){
				ofxCvGrayscaleImage g;
				g.allocate(StrategiW, StrategiH);
				g.set(255*[fade floatValue]/100.0);
				*images[i] -= g;
			}
		}
		
		
		
		
		for(int i=0;i<5;i++){
			for(int u=0;u<3;u++){
				LedLamp * lamp = [GetPlugin(DMXOutput) getLamp:u y:i];
				[lamp setLamp:0 g:0 b:0 a:0];
			}
		}
		
		
		NSColor * c = [player2Color color];		
		
		[GetPlugin(DMXOutput) makeNumber:area[1]/5000 r:[c redComponent]*254 g:[c greenComponent]*254 b:[c blueComponent]*254 a:[c alphaComponent]*190*1.0];
		
	}
	
	
}

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	ofEnableAlphaBlending();
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);

	
	
	
	blur->beginRender();
	blur->setupRenderWindow();
	
	//glPushMatrix();
	
	
	//	glTranslatef(0, +h*0.5, 0);       // shift origin up to upper-left corner.
	
	//	ofSetupScreen();
	


	
	
	
	
	
	for(int i=0;i<2;i++){

		if(i ==0){
			ofSetColor([[player1LineColor color] redComponent]*255, [[player1LineColor color] greenComponent]*255, [[player1LineColor color] blueComponent]*255,255.0);	
		} else {
			ofSetColor([[player2LineColor color] redComponent]*255, [[player2LineColor color] greenComponent]*255, [[player2LineColor color] blueComponent]*255,255.0);	
		}
		
		for(int u=0;u<contourFinder[i]->nBlobs;u++){
			vector<ofPoint> points;
			vector<ofxVec2f> hats;
			ofxVec2f  hatSmoother;
			ofPoint firstPoint1,firstPoint2;
			for(int j=0;j<contourFinder[i]->blobs[u].nPts;j++){
				ofxVec2f thisP = ofxVec2f(contourFinder[i]->blobs[u].pts[j].x/StrategiBlobW, contourFinder[i]->blobs[u].pts[j].y/StrategiBlobH);
				ofxVec2f prevP;
				if(j == 0){
					prevP = ofxVec2f(contourFinder[i]->blobs[u].pts[contourFinder[i]->blobs[u].nPts-1].x/StrategiBlobW, contourFinder[i]->blobs[u].pts[contourFinder[i]->blobs[u].nPts-1].y/StrategiBlobH);					
				}
				else if(j == contourFinder[i]->blobs[u].nPts){
					prevP = ofxVec2f(contourFinder[i]->blobs[u].pts[0].x/StrategiBlobW, contourFinder[i]->blobs[u].pts[0].y/StrategiBlobH);					
				}
				else{
					prevP = ofxVec2f(contourFinder[i]->blobs[u].pts[j-1].x/StrategiBlobW, contourFinder[i]->blobs[u].pts[j-1].y/StrategiBlobH);					
				}				
				ofxVec2f diff = thisP - prevP;
				diff.normalize();
				ofxVec2f hat = ofxVec2f(-diff.y, diff.x);
				if(j == 0){
					hatSmoother = hat;
				} else {
					float a = hatSmoother.angle(hat);
					hatSmoother.rotate(a*0.1);
					hatSmoother.normalize();
				}
				hats.push_back(hatSmoother);
				hats.push_back(-hatSmoother);
				//				hatSmoother *= (1+o)*(float)offsetSize/no;
				
				points.push_back(ofPoint(thisP.x+hatSmoother.x*[lineWidth floatValue]/100.0, thisP.y+hatSmoother.y*[lineWidth floatValue]/100.0));
				//	glTexCoord2f(50, 0.0f);     
				points.push_back(ofPoint(thisP.x-hatSmoother.x*[lineWidth floatValue]/100.0, thisP.y-hatSmoother.y*[lineWidth floatValue]/100.0));
				
				
				
				if(j == 0){
					firstPoint1 = ofPoint(thisP.x+hatSmoother.x*[lineWidth floatValue]/100.0, thisP.y+hatSmoother.y*[lineWidth floatValue]/100.0);
					firstPoint2 = ofPoint(thisP.x-hatSmoother.x*[lineWidth floatValue]/100.0, thisP.y-hatSmoother.y*[lineWidth floatValue]/100.0);
				}
			}
			
			//Draw it
			
			glBegin(GL_QUAD_STRIP);
			for(int j=0;j<points.size();j++){
				//	glTexCoord2f(0.0f, 0.0f);  
			//	ofxVec2f hat = hats[j] * ((o)*(float)offsetSize/no);
				glVertex2f(points[j].x, points[j].y);
				
			}
			glVertex2f(firstPoint1.x, firstPoint1.y);
			glVertex2f(firstPoint2.x, firstPoint2.y);
			glEnd();			
		}
	}
	
	blur->endRender();
	blur->blur(6, [outputBlurSlider floatValue]/100.0);
	
	glViewport(0,0,ofGetWidth(),ofGetHeight());	
	ofSetupScreen();
	glScaled(ofGetWidth(), ofGetHeight(), 1);
	ofEnableAlphaBlending();
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);


	[GetPlugin(ProjectionSurfaces) apply:"Back" surface:"Floor"];
	blur->draw(0, 0, 1, 1, true);
	glPopMatrix();
	
	
	[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Floor"];
	blur->draw(0, 0, 1, 1, true);
	glPopMatrix();


	[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Floor"];

	for(int i=0;i<2;i++){
		if(i ==0){
			ofSetColor([[player1Color color] redComponent]*255, [[player1Color color] greenComponent]*255, [[player1Color color] blueComponent]*255,255);	
		} else {
			ofSetColor([[player2Color color] redComponent]*255, [[player2Color color] greenComponent]*255, [[player2Color color] blueComponent]*255,255);	
		}	
		images[i]->draw(0, 0, 1,1);
	}
	glPopMatrix();
	
	[GetPlugin(ProjectionSurfaces) apply:"Back" surface:"Floor"];
	
	
	for(int i=0;i<2;i++){
		if(i ==0){
			ofSetColor([[player1Color color] redComponent]*255, [[player1Color color] greenComponent]*255, [[player1Color color] blueComponent]*255,255);	
		} else {
			ofSetColor([[player2Color color] redComponent]*255, [[player2Color color] greenComponent]*255, [[player2Color color] blueComponent]*255,255);	
		}	
		images[i]->draw(0, 0, 1,1);
	}
	
	
	glPopMatrix();
	glPopMatrix();
	glPopMatrix();

}

-(IBAction) restart:(id)sender{
	for(int i=0;i<2;i++){
		blobs = [[NSMutableArray array] retain];
		images[i]->set(0);
	}
	
}
@end

