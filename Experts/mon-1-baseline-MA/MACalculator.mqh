//+------------------------------------------------------------------+
//|                                                           ma.mqh |
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

input ushort MA_window_param = 300;

class MACalculator
{
   public:
      MACalculator()
      {
         MA_window = MA_window_param;
      }
   private:
      ushort MA_window;
      MqlRates rates[];
      int rate_num;
   public:
      double getSimpleMA()
      {
         rate_num = CopyRates(_Symbol, _Period, 0, MA_window+1, rates);
         double avg = -1;
         double sum;
         PrintFormat("rate_num: %d", rate_num);
         if(rate_num == MA_window+1)
         {
            sum = 0;
            for(int i=0; i<MA_window; i++)
               sum += rates[i].close;
            
            avg = sum/MA_window;
            
            return avg;    
         }
         else if(rate_num == -1)
         {
            Print("error occur when calling CopyRates()");
            return avg;
         }
         else // 0 < rate_num < 300
         {
            PrintFormat("data not enough for %d days", MA_window);
            avg = -2;
            return avg;
         }
      }
};