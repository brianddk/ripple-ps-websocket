// By d4n13 < https://github.com/d4n13 >.  Don't forget to tip!
//   Ripple credit TipJar: rEXJQNj9frFgG3Wk3smqGFVdMUX53c7Fw4
//
// Git:  https://github.com/d4n13/ripple-ps-websocket.git
// Note: See otherCmds directory for other commands.
// Reqs: Requires .NET 4.5 (aka 4.0.30319.18010; see Ref2)
// Erta: Warning MSB3644, benign, working to suppress
// Ref1: https://ripple.com/wiki/RPC_API#path_find
// Ref2: http://www.microsoft.com/en-us/download/details.aspx?id=30653
// Ref3: http://mutelight.org/using-the-little-known-built-in-net-json-parser
// Ref4: http://stackoverflow.com/a/9546397
//
using System;
using System.Text;
using System.Net.WebSockets;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Linq;
using System.Xml;
using System.Xml.XPath;
using System.Xml.Linq;
using System.ServiceModel.Web;
using System.Runtime.Serialization.Json;

namespace ripple_cmd
{
	// This class exists only to house the entry point.
	class MainApp {
		// The static method, Main, is the application's entry point.
		public static void Main() {
			// The guts...
			string snapSwap = "rMwjYedjc7qqtKYVLiAccJSmCwih4LnE2q";
			string bitStamp = "rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B";
			string create = @"
			{
			  ""command"": ""path_find"",
			  ""subcommand"": ""create"",
			  ""source_account"": ""~FROM~"",
			  ""destination_account"": ""~TO~"",
			  ""destination_amount"": ""~AMOUNT~/USD/~TO~"",
			  ""source_currencies"": [{""currency"":""USD"",""issuer"":""~FROM~""}]
			}
			";

			create = create.Replace("~AMOUNT~", "5000");
			create = create.Replace("~TO~", snapSwap);
			create = create.Replace("~FROM~", bitStamp);

			string status = @"
			{
			  ""command"": ""path_find"",
			  ""subcommand"": ""status""
			}
			";

			string close = @"
			{
			  ""command"": ""path_find"",
			  ""subcommand"": ""close""
			}
			";

			string st = "";
			string sa = "";
			int size = 1024;
	
			byte[] l;
			l = Encoding.ASCII.GetBytes(create);
			ArraySegment<byte> cr = new ArraySegment<byte>(l);
			l = Encoding.ASCII.GetBytes(status);
			ArraySegment<byte> sta = new ArraySegment<byte>(l);
			l = Encoding.ASCII.GetBytes(close);
			ArraySegment<byte> cl = new ArraySegment<byte>(l);

			ArraySegment<byte> rc = new ArraySegment<byte>(new byte[size]);

			ClientWebSocket w = new ClientWebSocket();
			CancellationToken c;
			Task t;
			Task<WebSocketReceiveResult> tr;

			t = w.ConnectAsync(new Uri("wss://s1.ripple.com:443"), c);
				 do { Thread.Sleep(100); }
				 while (!t.IsCompleted);

			t = w.SendAsync(cr, WebSocketMessageType.Text, true, c);
				 do { Thread.Sleep(100); }
				 while (!t.IsCompleted);

			t = w.SendAsync(sta, WebSocketMessageType.Text, true, c);
				 do { Thread.Sleep(100); }
				 while (!t.IsCompleted);

			do {

				 tr = w.ReceiveAsync(rc, c);
					 do { Thread.Sleep(10); }
					 while (!tr.IsCompleted);

				 sa = Encoding.Default.GetString(rc.Array);
				 st += sa.Substring(0, tr.Result.Count - 1);

			} while (tr.Result.Count == size);

			t = w.SendAsync(cl, WebSocketMessageType.Text, true, c);
				 do { Thread.Sleep(100); }
				 while (!t.IsCompleted);

			t = w.CloseAsync(WebSocketCloseStatus.NormalClosure, "NormalClosure", c);
				do { Thread.Sleep(100); }
				while (!t.IsCompleted);
			
			byte[] buffer = Encoding.Default.GetBytes(st);

			XmlReader reader = JsonReaderWriterFactory.CreateJsonReader(buffer, new XmlDictionaryReaderQuotas());

			XElement root = XElement.Load(reader);

			Console.WriteLine("\n===JSON===\n\n" + st);

			Console.WriteLine("\n===XML===\n\n" + root.ToString());
			
		}
	}
}