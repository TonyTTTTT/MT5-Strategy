//+------------------------------------------------------------------+
//|                                                    mon-1-ind.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+

class MonOneInd
{
   public:
      MonOneInd()
      {
         cnt = 0;
         range = 0;
      }  
   private:
      MqlRates rates[];
      // last_K = 0 -> red bar
      // last_K = 1 -> green bar
      int cnt;
      bool last_K;
      double last_open;
      double last_close;
      int cnv_K_idx;
      int tg_K_idx;
      bool tmp_K;
      int range;
      int rate_num;
      
   public:
      void findLastK()
      {
         // last_K = 0 -> red bar
         // last_K = 1 -> green bar
         cnt = 0;
         rate_num = CopyRates(_Symbol, _Period, 0, 2, rates);
         
         while(true)
         {
            if(rate_num != -1)
            {
               Print("Last K bar:");
               last_open = rates[0].open;
               last_close = rates[0].close;
               if(rates[0].open < rates[0].close)
               {
                  last_K = 0;
                  PrintFormat("RED open: %f, close: %f", rates[0].open, rates[0].close);
               }
               else {
                  last_K = 1;
                  PrintFormat("GREEN open: %f, close: %f", rates[0].open, rates[0].close);
               }
               if(rates[0].open != rates[0].close)
                  break;
               cnt ++;   
               rate_num = CopyRates(_Symbol, _Period, 0, 2+cnt, rates);  
            }
            else
            {
               Print("error occur when calling CopyRates()");
               break;
            }
         }
      }
   
      void findLastConverseNTarget()
      {
         int i;
         while(true)
         {
            range++;
            rate_num = CopyRates(_Symbol, _Period, 2+cnt-1, 10*range, rates);
            
            // for finding last converted K bar
            for(i=ArraySize(rates)-1; i>=0; i--)
            {
               if(rates[i].open == rates[i].close)
                  continue;
               tmp_K = rates[i].open > rates[i].close;
               if(last_K == 0 && tmp_K == 1)
               {
                  PrintFormat("Got the last conversion K bar at idx: %d", i);
                  PrintFormat("GREEN open: %f, close: %f", rates[i].open, rates[i].close);
                  cnv_K_idx = i;
                  break;
               }
               else if(last_K == 1 && tmp_K==0)
               {
                  PrintFormat("Got the last conversion K bar at idx: %d", i);
                  PrintFormat("RED open: %f, close: %f", rates[i].open, rates[i].close);
                  cnv_K_idx = i;
                  break;
               }
            }
            if(i==-1)
               continue;
               
            // for finding target K bar
            for(i=cnv_K_idx; i>=0; i--)
            {
               if(rates[i].open == rates[i].close)
                  continue;
               tmp_K = rates[i].open > rates[i].close;
               if(last_K == 0 && tmp_K == 0)
               {
                  PrintFormat("Got the target K bar at idx: %d", i);
                  PrintFormat("RED open: %f, close: %f, high: %f, low: %f", 
                              rates[i].open, rates[i].close, rates[i].high, rates[i].low);
                  tg_K_idx = i;
                  break;
               }
               else if(last_K == 1 && tmp_K == 1)
               {
                  PrintFormat("Got the target K bar at idx: %d", i);
                  PrintFormat("GREEN open: %f, close: %f, high: %f, low: %f", 
                              rates[i].open, rates[i].close, rates[i].high, rates[i].low);
                  tg_K_idx = i;
                  break;
               }
            }
            if(i!=-1)
               break;
         }
         PrintFormat("range: %d, cnv_K_idx: %d, tg_K_idx: %d, i: %d", range*10, cnv_K_idx, tg_K_idx, i);
      } 
      
      bool getLastK()
      {
         return last_K;
      } 
      
      double getLastClose()
      {
         return last_close;
      }
         
      double getTargetHigh()
      {
         return rates[tg_K_idx].high;
      }   
         
      double getTargetLow()
      {
         return rates[tg_K_idx].low;      
      }   
};