object DownloaderServer: TDownloaderServer
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 422
  Width = 561
  object IdHTTPServer: TIdHTTPServer
    Bindings = <>
    DefaultPort = 8899
    AutoStartSession = True
    OnCommandGet = IdHTTPServerCommandGet
    Left = 40
    Top = 24
  end
  object IdUDPServer: TIdUDPServer
    Bindings = <>
    DefaultPort = 8898
    ThreadedEvent = True
    OnUDPRead = IdUDPServerUDPRead
    Left = 200
    Top = 24
  end
  object IdUDPClient: TIdUDPClient
    Active = True
    BroadcastEnabled = True
    Host = '192.168.0.198'
    Port = 8898
    Left = 128
    Top = 24
  end
  object NetHTTPClient: TNetHTTPClient
    UserAgent = 'Embarcadero URI Client/1.0'
    Left = 32
    Top = 88
  end
end
