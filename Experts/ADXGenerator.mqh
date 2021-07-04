//+------------------------------------------------------------------+
//|                                                          ADX.mqh |
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
input ushort ADX_window_param = 14;
class ADXGenerator
{
   public:
      ADXGenerator()
      {
         ADX_window = ADX_window_param;
         getRates();
         calDMAvg();
         calTRAvg();
         calDIavg();
      }
   private:
      ushort ADX_window;
      double pDM_avg;
      double nDM_avg;
      double pDI_avg;
      double nDI_avg;
      double pDI_now;
      double nDI_now;
      double TR_avg;
      double pDM_ary[];
      double nDM_ary[];
      double TR_ary[];
      MqlRates rates[];
   private:
      void getRates()
      {
         int rate_num;
         rate_num = CopyRates(_Symbol, _Period, 0, ADX_window+2, rates);
         if(rate_num == -1)
         {
            Print("error occur when calling CopyRates()");
         }
      }
      
      void calDMAvg()
      {
         ArrayResize(pDM_ary, ADX_window);
         ArrayResize(nDM_ary, ADX_window);
         double tmp_rise;
         double tmp_decline;
         pDM_avg = 0;
         nDM_avg = 0;
         for(int i=0; i<ADX_window; i++)
         {
            tmp_rise = rates[i+1].high - rates[i].high;
            tmp_decline = rates[i].close - rates[i+1].close;
            if(tmp_rise >= tmp_decline && tmp_rise > 0)
            {
               pDM_ary[i] = tmp_rise;
               nDM_ary[i] = 0;
            } 
            else if(tmp_decline > tmp_rise && tmp_decline > 0)
            {
               pDM_ary[i] = 0;
               nDM_ary[i] = tmp_decline;
            }
            else
            {
               pDM_ary[i] = 0;
               nDM_ary[i] = 0;
            }
            pDM_avg += pDM_ary[i];
            nDM_avg += nDM_ary[i];
         }
         pDM_avg /=  ADX_window;
         nDM_avg /= ADX_window;
      }
      
      void calTRAvg()
      {
         ArrayResize(TR_ary, ADX_window);
         TR_avg = 0;
         for(int i=0; i<ADX_window; i++)
         {
            TR_ary[i] = MathMax(rates[i+1].high, rates[i].close) - MathMin(rates[i+1].low, rates[i].close);
            TR_avg += TR_ary[i];
         }
         TR_avg /= ADX_window;
      }
      
      void calDIavg()
      {
         pDI_avg = (pDM_avg/TR_avg) * 100;
         nDI_avg = (nDM_avg/TR_avg) * 100;
         pDI_now = (pDM_ary[ADX_window-1] / TR_ary[ADX_window-1]) * 100;
         nDI_now = (nDM_ary[ADX_window-1] / TR_ary[ADX_window-1]) * 100;
      }
      
      void calADX()
      {
         
      }
   public:
      double getpDI()
      {
         return pDI_now;
      }
      
      double getnDI()
      {
         return nDI_now;
      }
      
      double getADX()
      {
         return 1;
      }    
};