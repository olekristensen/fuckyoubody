
#include "Plugin.h"


@implementation ofPlugin
@synthesize name, enabled, header, controller, view;

- (BOOL) initWithController:(PluginManagerController*) c {
	[super init];
	[self setController:c];
	[self setName:NSStringFromClass(self->isa)];
	[self loadPluginNibFile];
	[self initPlugin];
	plugin = self;
}

- (void) initPlugin {

}

- (BOOL) loadPluginNibFile {
	
	if (![NSBundle loadNibNamed:[self name]  owner:self]){
		NSLog(@"Warning! Could not load the nib for %@ plugin",[self name]);
		return NO;
	}
	
	return YES;
	
}

- (void) setup{

}

- (void) draw{

}

- (void) update{

}


@end


/*#include "PluginController.h"
 #include "ProjectionSurfaces.h"
 #include "BlobTracking.h"
 */
/*FrostPlugin::FrostPlugin(){
 enabled = true;
 dt = 0;
 //	glDelegate = NULL;
 }
 
 */
/*void FrostPlugin::applyFloorProjection(){
 (getPlugin<ProjectionSurfaces*>(controller))->applyFloorProjection();
 }
 
 void FrostPlugin::applyWallProjection(){
 (getPlugin<ProjectionSurfaces*>(controller))->applyWallProjection();
 
 }
 
 ProjectionSurfaces* FrostPlugin::projection(){	
 return 	(getPlugin<ProjectionSurfaces*>(controller));
 }Tracker* FrostPlugin::blob(int n){	
 return 	(getPlugin<BlobTracking*>(controller)->trackers[n]);
 }*/