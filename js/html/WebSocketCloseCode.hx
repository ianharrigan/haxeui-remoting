/**
 * Check event.code in WebSocket.onclose.
 */
class WebSocketCloseCode
{
	public static inline var Normal = 1000;
	public static inline var Shutdown = 1001;
	public static inline var ProtocolError = 1002;
	public static inline var DataError = 1003;
	public static inline var Reserved1 = 1004;
	public static inline var NoStatus = 1005;
	public static inline var CloseError = 1006;
	public static inline var UTF8Error = 1007;
	public static inline var PolicyError = 1008;
	public static inline var TooLargeMessage = 1009;
	public static inline var ClientExtensionError = 1010;
	public static inline var ServerRequestError = 1011;
	public static inline var TLSError = 1015;
}