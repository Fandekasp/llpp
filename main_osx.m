#define CAML_NAME_SPACE

#include <pthread.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/callback.h>

@import Cocoa;

@interface MyDelegate : NSObject <NSApplicationDelegate>

- (void) applicationWillFinishLaunching:(NSNotification *)not;
- (void) applicationDidFinishLaunching:(NSNotification *)not;
- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication;

@end

@interface MyWindow : NSWindow

- (void) keyDown: (NSEvent *) event;
- (void) reshapeWidth:(int)w height:(int)h;
- (void) mouseUp: (NSEvent *)event;
- (void) mouseDown: (NSEvent *)event;

@end

MyWindow *window = nil;
char **global_argv = NULL;

CAMLprim value stub_set_title (value title)
{
    if (window == NULL) return Val_unit;
    [window setTitle:[NSString stringWithUTF8String:String_val(title)]];
    return Val_unit;
}

CAMLprim value stub_reshape (value w, value h)
{
    if (window == NULL) return Val_unit;
    [window reshapeWidth:Int_val (w) height:(Int_val (h))];
    return Val_unit;
}

@implementation MyWindow : NSWindow

- (void) reshapeWidth: (int) w height: (int)h
{
    NSRect frame = self.frame;
    [self setFrame: NSMakeRect (frame.origin.x, frame.origin.y, w, h) display:YES];
}

- (void) keyDown: (NSEvent *) event
{
    int key = [event keyCode];
    int mask = [event modifierFlags];
    caml_callback2 (*caml_named_value ("llpp_key_down"), Val_int (key), Val_int (mask));
}

- (void) keyUp: (NSEvent *) event
{
    int key = [event keyCode];
    int mask = [event modifierFlags];
    caml_callback2 (*caml_named_value ("llpp_key_up"), Val_int (key), Val_int (mask));
}

- (void) mouseDown: (NSEvent *) event
{
  int buttons = 0; // [event pressedMouseButtons];
    NSPoint loc = [event locationInWindow];
    int mask = [event modifierFlags];
    value args[] = {Val_int (buttons), Val_int(loc.x), Val_int(loc.y), Val_int(mask)};
    caml_callbackN (*caml_named_value ("llpp_mouse_down"), 4, args);
}

- (void) mouseUp: (NSEvent *) event
{
  int buttons = 0; // [event pressedMouseButtons];
    NSPoint loc = [event locationInWindow];
    int mask = [event modifierFlags];
    value args[] = {Val_int (buttons), Val_int(loc.x), Val_int(loc.y), Val_int(mask)};
    caml_callbackN (*caml_named_value ("llpp_mouse_up"), 4, args);
}

- (void) mouseMoved: (NSEvent *) event
{
  int buttons = 0; // [event pressedMouseButtons];
    NSPoint loc = [event locationInWindow];
    caml_callback2 (*caml_named_value ("llpp_mouse_moved"), Val_int (loc.x), Val_int (loc.y));
}

@end

@implementation MyDelegate

- (void) applicationWillFinishLaunching:(NSNotification *)not
{
    NSLog(@"applicationWillFinishLaunching");
    id menubar = [NSMenu new];
    id appMenuItem = [NSMenuItem new];
    [menubar addItem:appMenuItem];
    [NSApp setMainMenu:menubar];
    id appMenu = [NSMenu new];
    id appName = [[NSProcessInfo processInfo] processName];
    id quitTitle = [@"Quit " stringByAppendingString:appName];
    id quitMenuItem = [[NSMenuItem alloc] initWithTitle:quitTitle
                                                 action:@selector(terminate:)
                                                 keyEquivalent:@"q"];
    [appMenu addItem:quitMenuItem];
    [appMenuItem setSubmenu:appMenu];

    window = [[MyWindow alloc] initWithContentRect:NSMakeRect(0, 0, 400, 400)
                                         styleMask:(NSTitledWindowMask | NSResizableWindowMask)
                                           backing:NSBackingStoreBuffered
                                             defer:NO];

    window.acceptsMouseMovedEvents = YES;
    [window cascadeTopLeftFromPoint:NSMakePoint (20,20)];
    [window makeKeyAndOrderFront:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillTerminate:)
                                                 name:NSApplicationWillTerminateNotification
                                               object:nil];
}

- (void) appWillTerminate:(NSDictionary *)userInfo
{
  caml_callback (*caml_named_value ("llpp_quit"), Val_unit);
}

- (void) applicationDidFinishLaunching:(NSNotification *)not
{
    NSLog(@"applicationDidFinishLaunching");
    caml_startup (global_argv);
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
  return YES;
}

@end

int main(int argc, char **argv)
{
    global_argv = argv;
    @autoreleasepool {
        NSLog(@"Main_OSX");
        [NSApplication sharedApplication];
        [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
        id delegate = [MyDelegate new];
        [NSApp setDelegate:delegate];
        [NSApp activateIgnoringOtherApps:YES];
        [NSApp run];
    }
    return EXIT_SUCCESS;
}
