#include "ProjectionSurfaces.h"
#include "Arkade.h"

@implementation Arkade

-(void) setup{
	wall = new ofVideoPlayer();
	floor = new ofVideoPlayer();
	
	wall->loadMovie("arkade/Wall_1.mov");
	floor->loadMovie("arkade/Floor_c.mov");
//	wall->play();
//	floor->play();
}

-(void) update:(const CVTimeStamp *)outputTime{
	wall->idleMovie();
	floor->idleMovie();
}

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Floor"];
	floor->draw(0, 0,1,1);
	
	glPopMatrix();
	
	[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Backwall"];
	wall->draw(0, 0,[GetPlugin(ProjectionSurfaces) getAspect],1);
	
	glPopMatrix();
	
}
@end
