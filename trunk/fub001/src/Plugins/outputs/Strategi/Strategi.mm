//
//  Strategi.mm
//  openFrameworks
//
//  Created by Jonas Jongejan on 16/12/09.
//  Copyright 2009 HalfdanJ. All rights reserved.
//

#import "PluginIncludes.h"

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
		images[i]->allocate(640, 480);
		images[i]->set(0);
	}
	
	
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
					ofxPoint2f p = [b pts][u];//[GetPlugin(ProjectionSurfaces) convertFromProjection:[b pts][i] surface:[GetPlugin(ProjectionSurfaces) getProjectionSurfaceByName:"Front" surface:"Floor" ]];
					pointArray[u].x = int(p.x*640);
					pointArray[u].y = int(p.y*480);
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
				contourFinder[u]->findContours(*images[u], 20, (640*480)/1, 10, false, true);	
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
				g.allocate(640, 480);
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
	//[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Floor"];
	
	for(int i=0;i<2;i++){
		if(i ==0){
			ofSetColor([[player1Color color] redComponent]*255, [[player1Color color] greenComponent]*255, [[player1Color color] blueComponent]*255);	
		} else {
			ofSetColor([[player2Color color] redComponent]*255, [[player2Color color] greenComponent]*255, [[player2Color color] blueComponent]*255);	
		}
		images[i]->draw(0, 0, [GetPlugin(ProjectionSurfaces) getAspect],1);
		
		if(i ==0){
			ofSetColor([[player1LineColor color] redComponent]*255, [[player1LineColor color] greenComponent]*255, [[player1LineColor color] blueComponent]*255);	
		} else {
			ofSetColor([[player2LineColor color] redComponent]*255, [[player2LineColor color] greenComponent]*255, [[player2LineColor color] blueComponent]*255);	
		}
		
		for(int u=0;u<contourFinder[i]->nBlobs;u++){
		/*	texture->getTextureReference().bind();*/
/*#ifndef TARGET_OPENGLES
			glPushAttrib(GL_COLOR_BUFFER_BIT | GL_ENABLE_BIT);
#endif
			
			glHint(GL_POLYGON_SMOOTH_HINT, GL_NICEST);
			glEnable(GL_LINE_SMOOTH);
			
			//why do we need this?
			glEnable(GL_BLEND);
			glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
			*/
			glBegin(GL_POLYGON_SMOOTH);
			glBegin(GL_QUAD_STRIP);
			ofxVec2f  hatSmoother;
			for(int j=0;j<contourFinder[i]->blobs[u].nPts;j++){
				ofxVec2f thisP = ofxVec2f(contourFinder[i]->blobs[u].pts[j].x/640.0, contourFinder[i]->blobs[u].pts[j].y/480.0);
				ofxVec2f prevP;
				if(j == 0){
					prevP = ofxVec2f(contourFinder[i]->blobs[u].pts[contourFinder[i]->blobs[u].nPts-1].x/640.0, contourFinder[i]->blobs[u].pts[contourFinder[i]->blobs[u].nPts-1].y/480.0);					
				}
				else if(j == contourFinder[i]->blobs[u].nPts){
					prevP = ofxVec2f(contourFinder[i]->blobs[u].pts[0].x/640.0, contourFinder[i]->blobs[u].pts[0].y/480.0);					
				}
				else{
					prevP = ofxVec2f(contourFinder[i]->blobs[u].pts[j-1].x/640.0, contourFinder[i]->blobs[u].pts[j-1].y/480.0);					
				}				
				ofxVec2f diff = thisP - prevP;
				diff.normalize();
				ofxVec2f hat = ofxVec2f(-diff.y, diff.x);
				if(j == 0){
					hatSmoother = hat;
				} else {
					hatSmoother += hat * 0.1;
					hatSmoother.normalize();
				}
			//	glTexCoord2f(0.0f, 0.0f);  
				glVertex2f(thisP.x+hatSmoother.x*[lineWidth floatValue]/100.0, thisP.y+hatSmoother.y*[lineWidth floatValue]/100.0);
			//	glTexCoord2f(50, 0.0f);     
				glVertex2f(thisP.x-hatSmoother.x*[lineWidth floatValue]/100.0, thisP.y-hatSmoother.y*[lineWidth floatValue]/100.0);
			}
			glEnd();
			//texture->getTextureReference().unbind();
			
		}
	}
	
	//glPopMatrix();
}

-(IBAction) restart:(id)sender{
	for(int i=0;i<2;i++){
		blobs = [[NSMutableArray array] retain];
		images[i]->set(0);
	}
	
}
@end
