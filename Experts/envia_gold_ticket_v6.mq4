//+------------------------------------------------------------------+
//|                                                  GOLD SPIRIT.mq4 |
//|                                                   Copyright 2021 |
//|                                     DEVELOPER ISAQUE R. FERREIRA |
//+------------------------------------------------------------------+

#property copyright "Copyright 2021"
#property version "4.00"
#property link "https://t.me/isaquerr25"
#property description "DEVELOPER ISAQUE R. FERREIRA"
#property description "Mais info"
#property link "https://t.me/isaquerr25"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 DarkOrchid

//+------------------------------------------------------------------+
//| Expert variaveis                                                 |
//+------------------------------------------------------------------+
#include <mql4-http.mqh>
double ma21_ant, ma9, ma21, ma9_ant;
datetime ctm[1];
datetime LastTime;
double lot, slv, tpv;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#include <ghttp.mqh>
#include <JAson.mqh>
#include <Arrays\ArrayObj.mqh>
#include <Web.mqh>
extern string iq_server = "copye";
extern string id_save = "copy";
extern string address = "192.168.1.66";
extern string door = "4000";
extern int MAGICNUMBER = 1;
#import "Wininet.dll"
int InternetOpenW(string, int, string, string, int);
int InternetConnectW(int, string, int, string, string, int, int, int);
int InternetOpenUrlW(int, string, string, int, int, int);
int InternetReadFile(int, string, int, int &OneInt[]);
int InternetCloseHandle(int);
int HttpOpenRequestW(int, string, string, string, string, string, int, int);
bool HttpSendRequestW(int, string, int, string, int);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HttpSendRequestW(int hRequest, string lpszHeaders, int dwHeadersLength, char &lpOptional[], int dwOptionalLength);

#import "Kernel32.dll"
bool MoveFileExW(string &lpExistingFileName, string &lpNewFileName, int dwFlags);
#import
#define MOVEFILE_REPLACE_EXISTING 0x1
CJAVal log_close_all(NULL, jtUNDEF);

CJAVal log_open_all(NULL, jtUNDEF);
bool progressConst = true;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
{
	log_close_all.Deserialize(dict_close());
	log_open_all.Deserialize(dict_open());
	int fileHandle = 0;
	if (!FileIsExist(id_save + "_1550.txt", 0))
	{
		Print("File Not _1550, Regenerating.....");
		fileHandle = FileOpen(id_save + "_1550.txt", FILE_READ | FILE_WRITE | FILE_TXT);
		FileWriteString(fileHandle, "");
		FileClose(fileHandle);

		Print("File Not _1557, Regenerating.....");
		fileHandle = FileOpen(id_save + "_1557.txt", FILE_READ | FILE_WRITE | FILE_TXT);
		FileWriteString(fileHandle, "");
		FileClose(fileHandle);

		Print("File Not _1556, Regenerating.....");
		fileHandle = FileOpen(id_save + "_1556.txt", FILE_READ | FILE_WRITE | FILE_TXT);
		FileWriteString(fileHandle, "");
		FileClose(fileHandle);
	}

	HideTestIndicators(TRUE);
	EventSetTimer(60);

	//---
	return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
	//--- destroy timer
	EventKillTimer();
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
	bool review = false;
	
	progressConst = false;
	for (int i = 0; i < OrdersTotal(); i++)
	{
	
		if (OrderSelect(i, SELECT_BY_POS) == false)
			continue;
		if (OrderMagicNumber() == MAGICNUMBER && OrderSymbol() == Symbol())
		{
			string log_open_str = log_open_all[(string)OrderTicket()].ToStr();
			if ((log_open_str == "" || log_open_str == NULL))
			{
				if (OrderType() == 1 || OrderType() == 0)
				{
					review = true;
				}
			}
		}
	}
	if (!review)
	{
		for (int i = 0; i < OrdersHistoryTotal(); i++)
		{
			if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) == false)
				continue;
			if (OrderMagicNumber() == MAGICNUMBER && OrderSymbol() == Symbol())
			{
				string log_close_str = log_close_all[(string)OrderTicket()].ToStr();
				string log_open_str = log_open_all[(string)OrderTicket()].ToStr();
				if (log_open_str == "gravado" && log_close_str != "fechamento")
				{
					review = true;
					break;
				}
			}
		}
	}
	if (review)
	{
		find_open();
		find_close();
		clear_cache();
		log_close_all.Deserialize(dict_close());
		log_open_all.Deserialize(dict_open());
		progressConst = true;
	}else{
		progressConst = true;
	}
	
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{

	Print("rodando", Symbol());
	//---
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
	const long &lparam,
	const double &dparam,
	const string &sparam)
{
	//---
}
void clear_cache()
{
	Print("clear_cache");	
	int enrodo = 0;
	for (int i = 0; i < OrdersTotal(); i++)
	{

		if (OrderSelect(i, SELECT_BY_POS) == false)
			continue;
		if (OrderMagicNumber() == MAGICNUMBER && OrderSymbol() == Symbol())
		{
			enrodo = OrdersTotal();
		}
	}
	if (enrodo == 0)
	{
		int file_handle = FileOpen(id_save + "_1550.txt", FILE_WRITE | FILE_TXT);
		if (file_handle != INVALID_HANDLE)
		{
			FileFlush(file_handle);
			FileClose(file_handle);
		}
		else
		{
			Print("não funcionou");
			PrintFormat("Error, code = %d", GetLastError());
		}
		file_handle = FileOpen(id_save + "_1557.txt", FILE_WRITE | FILE_TXT);
		FileFlush(file_handle);
		FileClose(file_handle);
		file_handle = FileOpen(id_save + "_1556.txt", FILE_WRITE | FILE_TXT);
		FileFlush(file_handle);
		FileClose(file_handle);
		Print("limpou ", Symbol());
	}
}

void find_open()
{

	Print("find_open");	
	CJAVal log_open(NULL, jtUNDEF);
	log_open.Deserialize(dict_open());
	CJAVal log_close(NULL, jtUNDEF);
	log_close.Deserialize(dict_close());
	CJAVal resume_deserialize(NULL, jtUNDEF);
	for (int i = 0; i < OrdersTotal(); i++)
	{

		if (OrderSelect(i, SELECT_BY_POS) == false)
			continue;

		string log_open_str = log_open[(string)OrderTicket()].ToStr();
		string log_close_str = log_close[(string)OrderTicket()].ToStr();
		bool have_in_list = false;
		string type = "normal";

		if (OrderMagicNumber() == MAGICNUMBER && OrderSymbol() == Symbol())
		{

			if ((log_open_str == "" || log_open_str == NULL) && log_close_str != "fechamento")
			{
				have_in_list = false;
			}
			else
			{
				have_in_list = true;
			}
			if (!have_in_list)
			{
				string direcao = "buy";
				switch (OrderType())
				{
				case 1:
					direcao = ("sell");
					break;
				case 0:
					direcao = ("buy");
					break;
				default:
					have_in_list = true;
					break;
				}
				if (have_in_list)
				{
					continue;
				}

				string js = ("{\"ticket\":\"" + (string)OrderTicket() + "\",\"abertura\":\"" +
					iq_server + "\",\"direcao\":\"" + direcao +
					"\",\"par\":\"" + (string)OrderSymbol() + "\",\"type\":\"" + type +
					"\",\"lots\":\"" + (string)OrderLots() + "\",\"status\":\"abertura\"}");
			

				string resume = httpPost(address, door, "set_sinal", js);
				resume_deserialize.Deserialize(resume);
				string value = resume_deserialize["status"].ToStr();
				if (value == "gravado" || value == "jaTem")
				{
					
					save_open_log((string)OrderTicket(), "gravado");
					
				}				
			}
		}
	}
}

void find_close()
{
	Print("find_close");	
	CJAVal log_open(NULL, jtUNDEF);
	log_open.Deserialize(dict_open());
	CJAVal log_close(NULL, jtUNDEF);
	log_close.Deserialize(dict_close());
	for (int i = 0; i < OrdersHistoryTotal(); i++)
	{

		if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) == false)
			continue;
		if (OrderMagicNumber() == MAGICNUMBER && OrderSymbol() == Symbol())
		{
			string log_open_str = log_open[(string)OrderTicket()].ToStr();
			string log_close_str = log_close[(string)OrderTicket()].ToStr();

			bool have_in_list = false;

			if (log_open_str == "gravado" && log_close_str != "fechamento")
			{
				have_in_list = false;
			}
			else
			{
				have_in_list = true;
			}
			if (!have_in_list)
			{
				Print(" fechando orden", OrderTicket(), " do para ", Symbol());
				string js = ("{\"ticket\":\"" + (string)OrderTicket() + "\",\"status\":\"fechamento\"}");
				log_open[(string)OrderTicket()] = "fechamento";
				string resume = httpPost(address, door, "auter_sinal", js);
				CJAVal resume_deserialize(NULL, jtUNDEF);
				resume_deserialize.Deserialize(resume);
				if (resume_deserialize["status"].ToStr() == "fechamento")
				{
					save_close_log((string)OrderTicket());
				}
			}
		}
	}
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void save_open_log(string dict_, string atributo_)
{

	
	int h = FileOpen(id_save + "_1550.txt", FILE_READ | FILE_WRITE | FILE_ANSI | FILE_TXT);
	if (h == INVALID_HANDLE)
	{
		PrintFormat("Failed to open %s file, Error code = %d",id_save + "_1550.txt",GetLastError());
	}
	else
	{
		FileSeek(h, 0, SEEK_END);
		FileWrite(h, "{\"" + dict_ + "\":\"" + atributo_ + "\"}");
		;
	}
	FileClose(h);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void save_close_log(string id__)
{


	int h = FileOpen(id_save + "_1557.txt", FILE_READ | FILE_WRITE | FILE_ANSI | FILE_TXT);
	if (h == INVALID_HANDLE)
	{
		PrintFormat("Failed to open %s file, Error code = %d",id_save + "_1557.txt",GetLastError());
	}
	else
	{
		FileSeek(h, 0, SEEK_END);
		FileWrite(h, "{\"" + id__ + "\":\"fechamento\"}");
	}
	FileClose(h);
	
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string httpPost(string strUrl, string port, string idxfile = "get_to_id", string identi_op = "")
{

	string headers = "Content-Type: application/json";
	string js;
	if (idxfile == "get_to_id")
		js = "{\"id\":" + identi_op + "}";
	else
		js = identi_op;
	uchar data[];
	uchar result[];
	string result_hdr;

	StringToCharArray(js, data);

	int HttpOpen = hSession(false);
	string serve_header = "";
	char resultado[];
	int offget;
	printf("try send");
	printf("http://" + address + ":"+port+"/api/" + idxfile +"------  "+ identi_op);
	
	if (idxfile == "access_account")
	{
	   printf("if");
		WebRequest(
				"POST",																			// HTTP method
				"http://" + address + ":"+port+"/userk/" + idxfile,            // URL
				headers,																			// headers
				100000000,																		// timeout
				data,																				// the array of the HTTP message body
				result,																			// an array containing server response data
				result_hdr																		// headers of server response
		);
	}
	else
	{
	   printf("else");
		WebRequest(
				"POST",																		// HTTP method
				"http://" + address + ":"+port+"/api/" + idxfile,           // URL
				headers,																		// headers
				10000,																	// timeout
				data,																			// the array of the HTTP message body
				result,																		// an array containing server response data
				result_hdr																	// headers of server response
		);
		printf("passe");
	}
	// //alert("Error when trying to call APIU* : ", GetLastError());
   printf("result");
	string DOTStr = CharArrayToString(result, 0);
   printf(DOTStr);
	return (DOTStr);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string dict_open()
{
	Print("dict_open");
	int f = FileOpen(id_save + "_1550.txt", FILE_READ | FILE_TXT);
	int i = 0;
	string str;
	string backString = "";
	while (FileIsEnding(f) == False)
	{
		str = FileReadString(f);
		backString = backString + str;
	}
	StringReplace(backString, "}", "");
	StringReplace(backString, "{", "");
	backString = "{" + backString + "}";
	FileClose(f);
	return (backString);
}
string dict_close()
{
	Print("dict_close");	
	int f = FileOpen(id_save + "_1557.txt", FILE_READ | FILE_TXT);
	int i = 0;
	string str;
	string backString = "";
	while (FileIsEnding(f) == False)
	{
		str = FileReadString(f);
		backString = backString + str;
	}
	StringReplace(backString, "}", ",");
	StringReplace(backString, "{", "");
	backString = "{" + backString + "}";
	FileClose(f);
	return (backString);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
