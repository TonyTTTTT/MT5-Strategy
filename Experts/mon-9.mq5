//+------------------------------------------------------------------+
//|                                                         test.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include "send-transaction-close.mqh"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

//input ushort ADX_window_param = 14;
input short MA_X_window_param = 5;
input short MA_Y_window_param = 5;
input short MA_Z_window_param = 5;
input short RSI_window_param = 5;
input ENUM_TIMEFRAMES peroid_param = PERIOD_CURRENT;
input ENUM_APPLIED_PRICE applied_price_param = PRICE_CLOSE;
MqlRates rates[];
OrderSender order_sender();

int MA_X_handle;
int MA_Y_handle;
int MA_Z_handle;
int RSI_handle;
int order_response;

double MA_X[];
double MA_Y[];
double MA_Z[];
double rsi_buffer[];
double last_rsi = -1;
double MA_max, MA_min;

double last_rsi_u50_close_price = INT_MAX;
double last_rsi_d50_close_price = INT_MIN;

double buy_point_low_price = INT_MIN;
double sell_point_high_price = INT_MAX;

double sell_point_close_price = INT_MAX;
double buy_point_close_price = INT_MIN;

/*double last_rsi_u50_redk_low_price = INT_MIN;
double last_rsi_d50_greenk_high_price = INT_MAX;*/

double last_rsi_u50_redk_close_price = INT_MIN;
double last_rsi_d50_greenk_close_price = INT_MAX;

bool red_k = true;


int OnInit()
  {
//---
   //ChartSetSymbolPeriod(0,"XAUUSD",_Period);
   Print("Successful initialization!");
   Print("current symbol: ", _Symbol);
   Print("current peroid: ", PeriodSeconds());
   MA_X_handle = iMA(_Symbol, peroid_param, MA_X_window_param, 0, MODE_EMA, applied_price_param);
   MA_Y_handle = iMA(_Symbol, peroid_param, MA_Y_window_param, 0, MODE_EMA, applied_price_param);
   MA_Z_handle = iMA(_Symbol, peroid_param, MA_Z_window_param, 0, MODE_EMA, applied_price_param);
   RSI_handle = iRSI(_Symbol, peroid_param, RSI_window_param, applied_price_param);
   EventSetTimer(PeriodSeconds(peroid_param));
   OnTimer();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+

void OnTimer()
{
   Print("execute OnTimer!");

   int rate_num = CopyRates(_Symbol, _Period, 0, 2, rates);
   
   if(rate_num != -1) {
      if (rates[0].close > rates[0].open)
         red_k = true;
      else
         red_k = false;   
   } else  {
      Print("Error occur when calling CopyRates()");
   }  


   int MA_X_num = CopyBuffer(MA_X_handle, 0, 0, 2, MA_X);
   int MA_Y_num = CopyBuffer(MA_Y_handle, 0, 0, 2, MA_Y);
   int MA_Z_num = CopyBuffer(MA_Z_handle, 0, 0, 2, MA_Z);
   
   if(MA_X_num != -1)
      PrintFormat("MA_X(%s): %f, last MA_X: %f", applied_price_param, MA_X[1], MA_X[0]);
   if(MA_X_num == -1)
      Print("Error occur when calling MA_X");
   
   if(MA_Y_num != -1)
      PrintFormat("MA_Y(%s): %f, last MA_Y: %f", applied_price_param, MA_Y[1], MA_Y[0]);
   if(MA_Y_num == -1)
      Print("Error occur when calling MA_Y");
      
   if(MA_Z_num != -1)
      PrintFormat("MA_Z(%s): %f, last MA_Z: %f", applied_price_param, MA_Z[1], MA_Z[0]);
   if(MA_Z_num == -1)
      Print("Error occur when calling MA_Z");
      
   MA_max = MathMax(MA_X[0], MA_Y[0]);
   MA_max = MathMax(MA_max, MA_Z[0]);
   MA_min = MathMin(MA_X[0], MA_Y[0]);
   MA_min = MathMin(MA_min, MA_Z[0]);

   int RSI_num = CopyBuffer(RSI_handle,0,0,1,rsi_buffer);
   
   if (RSI_num != -1) {
      PrintFormat("RSI: %f", rsi_buffer[0]);
   } else {
      Print("error occur when calling RSI");
   }
      

   if (PositionsTotal() != 0) {
      string type = EnumToString((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE));
      PrintFormat("current position type: %s", type);
      if (type == "POSITION_TYPE_BUY") {
         if (rsi_buffer[0] < 50 && rates[0].close > buy_point_close_price) {
            PrintFormat("BUY stop profit, current close: %f, buy price: %f", rates[0].close, buy_point_close_price);
            order_sender.sell();
         } else if (rates[0].close < buy_point_low_price) {
            PrintFormat("BUY stop loss, current close: %f, buy_point_low_price: %f", rates[0].close, buy_point_low_price);
            order_sender.sell();
         }   
      } else {
         if (rsi_buffer[0] >= 50 && rates[0].close < sell_point_close_price) {
            PrintFormat("SELL stop profit, current close: %f, sell price: %f", rates[0].close, sell_point_close_price);
            order_sender.buy();
         } else if (rates[0].close > sell_point_high_price) {
            PrintFormat("SELL stop loss, current close: %f, sell_point_high_price: %f", rates[0].close, sell_point_high_price);
            order_sender.buy();
         }
      }   
   }

   if (rsi_buffer[0] >= 60) {
      if (rates[0].close>last_rsi_u50_close_price && rates[0].close>MA_max) {
         PrintFormat("Meet buy strategy 1\ncurrent price: %f, last rsi up 50 close price: %f,  %d_MA: %f\nBuy!", rates[0].close, last_rsi_u50_close_price, MA_X_window_param, MA_X[0]);
         order_response = order_sender.buy();
         if (PositionsTotal() == 0)
            order_response = order_sender.buy();
         if (order_response == 0)   
            buy_point_low_price = rates[0].low;
         buy_point_close_price = rates[0].close;      
      }
      if (last_rsi>0 && last_rsi<60)
         last_rsi_u50_close_price = rates[0].close;
   } else if (rsi_buffer[0] < 60) {
      if (rates[0].close<last_rsi_d50_close_price && rates[0].close<MA_min) {
         PrintFormat("Meet sell strategy 1\ncurrent price: %f, last rsi down 50 close price: %f,  %d_MA: %f\nSell!", rates[0].close, last_rsi_d50_close_price, MA_X_window_param, MA_X[0]);
         order_response = order_sender.sell();
         if (PositionsTotal() == 0)
            order_response = order_sender.sell();
         if (order_response == 0)      
            sell_point_high_price = rates[0].high;
         sell_point_close_price = rates[0].close;      
      }
      if (last_rsi >= 60)
         last_rsi_d50_close_price = rates[0].close;
   }
   
   Print("====================================================");
   last_rsi = rsi_buffer[0];
}