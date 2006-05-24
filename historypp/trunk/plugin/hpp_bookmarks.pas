{-----------------------------------------------------------------------------
 hpp_bookmarks.pas (historypp project)

 Version:   1.5
 Created:   02.04.2006
 Author:    Oxygen

 [ Description ]

 Hello, this is dummy text


 [ History ]

 1.5 (02.04.2006)
   First version

 [ Modifications ]
 none

 [ Known Issues ]
 none

 Copyright (c) Art Fedorov, 2006
-----------------------------------------------------------------------------}

unit hpp_bookmarks;

interface

uses m_globaldefs, m_api;

type
  TEventData = packed record
    hDBEvent: DWord;
    CRC32: DWord;
    Timestamp: DWord;
    Position: DWord;
  end;

  TBookmarkServer = class(TObject)
  private
    hookEventDeleted,hookEventAdded: THandle;
  protected
    procedure EventDeleted(hContact,hDBEvent: THandle);
    procedure EventAdded(hContact,hDBEvent: THandle);
  public
    constructor Create;
    destructor Destroy; override;

    function AddBookmark(hContact, hDBEvent: THandle): Integer;
    function GetBookmark(hContact, hDBEvent: THandle): Integer;
    function DeleteBookmark(Bookmark: Integer): Integer; overload;
    function DeleteBookmark(hContact, hDBEvent: THandle): Integer; overload;
  end;

var
  BookmarkServer: TBookmarkServer;

procedure hppInitBookmarkServer;
procedure hppDeinitBookmarkServer;

implementation

procedure hppInitBookmarkServer;
begin
  BookmarkServer := TBookmarkServer.Create;
end;

procedure hppDeinitBookmarkServer;
begin
  BookmarkServer.Free;
end;

function EventDeletedHelper(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
// wParam: hContact, lParam: hDBEvent
begin
  if Assigned(BookmarkServer) then
    BookmarkServer.EventDeleted(wParam,lParam);
  Result := 0;
end;

function EventAddedHelper(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
// wParam: hContact, lParam: hDBEvent
begin
  if Assigned(BookmarkServer) then
    BookmarkServer.EventAdded(wParam,lParam);
  Result := 0;
end;

{ TBookmarkServer }

function TBookmarkServer.AddBookmark(hContact, hDBEvent: THandle): Integer;
begin
  Result := 0;
end;

function TBookmarkServer.GetBookmark(hContact, hDBEvent: THandle): Integer;
begin
  Result := -1;
end;

function TBookmarkServer.DeleteBookmark(Bookmark: Integer): Integer;
begin
  Result := 0;
end;

function TBookmarkServer.DeleteBookmark(hContact, hDBEvent: THandle): Integer;
var
  bm: integer;
begin
  bm := GetBookmark(hContact, hDBEvent);
  if bm <> -1 then
    Result := Self.DeleteBookmark(bm)
  else
    Result := bm;
end;

constructor TBookmarkServer.Create;
begin
  inherited;
  hookEventDeleted := PluginLink.HookEvent(ME_DB_EVENT_DELETED,EventDeletedHelper);
  hookEventAdded := PluginLink.HookEvent(ME_DB_EVENT_ADDED,EventAddedHelper);
end;

destructor TBookmarkServer.Destroy;
begin
  PluginLink.UnhookEvent(hookEventDeleted);
  PluginLink.UnhookEvent(hookEventAdded);
  BookmarkServer := nil;
  inherited;
end;

procedure TBookmarkServer.EventAdded(hContact, hDBEvent: THandle);
begin
  ;
end;

procedure TBookmarkServer.EventDeleted(hContact, hDBEvent: THandle);
begin
  DeleteBookmark(hContact, hDBEvent);
end;

end.
