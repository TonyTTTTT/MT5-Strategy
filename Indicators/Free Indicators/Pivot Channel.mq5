//+------------------------------------------------------------------+
//|                                                Pivot Channel.mq5 |
//|                              Copyright 2009-2024, MetaQuotes Ltd |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "2009-2024, MetaQuotes Ltd"
#property link        "http://www.mql5.com"
#property description "Pivot Daily Channels"

#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   9
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrange
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrTeal
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrGreen
//--- labels
#property indicator_label1  "PP"
#property indicator_label2  "R1"
#property indicator_label3  "R2"
#property indicator_label4  "S1"
#property indicator_label5  "S2"
#property indicator_label6  "M1"
#property indicator_label7  "M2"
#property indicator_label8  "M3"
#property indicator_label9  "M4"

//--- input parameters
input bool    InpShowLevelsM=false; // show M levels
input bool    InpShowLabel  =true;  // show price of level

//--- indicator buffers
double        ExtPPBuffer[];
double        ExtR1Buffer[];
double        ExtR2Buffer[];
double        ExtS1Buffer[];
double        ExtS2Buffer[];
//--- additional indicator buffers
double        ExtM1Buffer[];
double        ExtM2Buffer[];
double        ExtM3Buffer[];
double        ExtM4Buffer[];

//--- unique prefix to identify indicator objects
string ExtPrefixUniq;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- check current timeframe
   if(PeriodSeconds()>PeriodSeconds(PERIOD_D1))
     {
      Alert("Timeframe of chart must be D1 or lower. Exit");
      return(INIT_FAILED);
     }

//--- define buffers
   SetIndexBuffer(0, ExtPPBuffer);
   SetIndexBuffer(1, ExtR1Buffer);
   SetIndexBuffer(2, ExtR2Buffer);
   SetIndexBuffer(3, ExtS1Buffer);
   SetIndexBuffer(4, ExtS2Buffer);
   if(InpShowLevelsM)
     {
      SetIndexBuffer(5, ExtM1Buffer, INDICATOR_DATA);
      SetIndexBuffer(6, ExtM2Buffer, INDICATOR_DATA);
      SetIndexBuffer(7, ExtM3Buffer, INDICATOR_DATA);
      SetIndexBuffer(8, ExtM4Buffer, INDICATOR_DATA);
      //--- set plot type
      PlotIndexSetInteger(5, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(6, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(7, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(8, PLOT_DRAW_TYPE, DRAW_LINE);
      //--- set line style
      PlotIndexSetInteger(5, PLOT_LINE_STYLE, STYLE_DASH);
      PlotIndexSetInteger(6, PLOT_LINE_STYLE, STYLE_DASH);
      PlotIndexSetInteger(7, PLOT_LINE_STYLE, STYLE_DASH);
      PlotIndexSetInteger(8, PLOT_LINE_STYLE, STYLE_DASH);
      //--- set line color
      PlotIndexSetInteger(5, PLOT_LINE_COLOR, clrGold);
      PlotIndexSetInteger(6, PLOT_LINE_COLOR, clrGold);
      PlotIndexSetInteger(7, PLOT_LINE_COLOR, clrGold);
      PlotIndexSetInteger(8, PLOT_LINE_COLOR, clrGold);
     }
   else
     {
      SetIndexBuffer(5, ExtM1Buffer, INDICATOR_CALCULATIONS);
      SetIndexBuffer(6, ExtM2Buffer, INDICATOR_CALCULATIONS);
      SetIndexBuffer(7, ExtM3Buffer, INDICATOR_CALCULATIONS);
      SetIndexBuffer(8, ExtM4Buffer, INDICATOR_CALCULATIONS);

     }

//--- indicator name
   IndicatorSetString(INDICATOR_SHORTNAME, "Pivot Daily Channels");
//--- number of digits of indicator value
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

//--- prepare prefix for objects
   string number=StringFormat("%I64d", GetTickCount64());
   ExtPrefixUniq=StringSubstr(number, StringLen(number)-4);
   ExtPrefixUniq=ExtPrefixUniq+"_PP";
   Print("Indicator \"Pivot Channels\" started, prefix=", ExtPrefixUniq);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   static MqlRates LAST_DAY[];    // previous day
   static datetime last_time=0;   // reference time
   static datetime error_time=0;  // error output time

//--- if the indicator has previously been calculated, start from the bar preceding the last one
   int start=prev_calculated-1;

//--- if this is the first calculation of the indicator, start from the first bar on the chart
   if(prev_calculated==0)
      start=0;

//--- calculate levels for all bars in a loop
   for(int i=start; i<rates_total; i++)
     {
      //--- get day opening time for the current bar
      datetime rem_seconds=time[i]%PeriodSeconds(PERIOD_D1);
      datetime open_time=time[i]-rem_seconds;

      //--- if the opening time is different from the reference time, update LAST_DAY - level calculations will be based on this value
      if(open_time!=last_time)
        {
         //--- If you're running the indicator on this symbol for the first time,
         //--- first open the D1 chart for the symbol to initiate immediate downloading of daily bars
         //--- if getting the current timeframe bars for the specified day fails
         if(CopyRates(Symbol(), PERIOD_D1, open_time-1, 1, LAST_DAY)!=-1)
           {
            //--- remember the reference time
            last_time=open_time;
           }
         else
           {
            //--- generate error messages no more than once a minute
            if(TimeCurrent()>=error_time)
              {
               error_time=TimeCurrent()+60;
               Print("Failed to get previous day by CopyRates(Symbol(), PERIOD_D1, error ", GetLastError());
              }
            return(prev_calculated);
           }
        }

      //--- calculate Pivot levels
      double pivot_point=(LAST_DAY[0].high+LAST_DAY[0].low+LAST_DAY[0].close)/3;
      double r1=2*pivot_point-LAST_DAY[0].low;
      double r2=pivot_point+(LAST_DAY[0].high-LAST_DAY[0].low);
      double s1=2*pivot_point-LAST_DAY[0].high;
      double s2=pivot_point-(LAST_DAY[0].high-LAST_DAY[0].low);

      //--- write values into buffers
      ExtPPBuffer[i]=pivot_point;
      ExtR1Buffer[i]=r1;
      ExtR2Buffer[i]=r2;
      ExtS1Buffer[i]=s1;
      ExtS2Buffer[i]=s2;

      //--- additional levels
      double m1=(s1+s2)/2;
      double m2=(s1+pivot_point)/2;
      double m3=(r1+pivot_point)/2;
      double m4=(r1+r2)/2;
      ExtM1Buffer[i]=m1;
      ExtM2Buffer[i]=m2;
      ExtM3Buffer[i]=m3;
      ExtM4Buffer[i]=m4;
     }

//--- draw labels on levels
   if(InpShowLabel)
     {
      ShowPriceLevels(time[rates_total-1], rates_total-1);
      ChartRedraw();
     }

//--- succesfully calculated
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- delete all our graphical objects after use
   Print("Indicator \"Pivot Channel\" stopped, delete all objects with prefix=", ExtPrefixUniq);
   ObjectsDeleteAll(0, ExtPrefixUniq, 0, OBJ_ARROW_RIGHT_PRICE);
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//|  Show prices' levels                                             |
//+------------------------------------------------------------------+
void ShowPriceLevels(datetime time, int last_index)
  {
   ShowRightPrice(ExtPrefixUniq+"_PP", time, ExtPPBuffer[last_index], clrBlue);
   ShowRightPrice(ExtPrefixUniq+"_R1", time, ExtR1Buffer[last_index], clrOrange);
   ShowRightPrice(ExtPrefixUniq+"_R2", time, ExtR2Buffer[last_index], clrRed);
   ShowRightPrice(ExtPrefixUniq+"_S1", time, ExtS1Buffer[last_index], clrTeal);
   ShowRightPrice(ExtPrefixUniq+"_S2", time, ExtS2Buffer[last_index], clrGreen);
   if(InpShowLevelsM)
     {
      ShowRightPrice(ExtPrefixUniq+"_M1", time, ExtM1Buffer[last_index], clrGold);
      ShowRightPrice(ExtPrefixUniq+"_M2", time, ExtM2Buffer[last_index], clrGold);
      ShowRightPrice(ExtPrefixUniq+"_M3", time, ExtM3Buffer[last_index], clrGold);
      ShowRightPrice(ExtPrefixUniq+"_M4", time, ExtM4Buffer[last_index], clrGold);
     }
  }
//+------------------------------------------------------------------+
//| Create or Update "Right Price Label" object                      |
//+------------------------------------------------------------------+
bool ShowRightPrice(const string name, datetime time, double price, color clr)
  {
   if(!ObjectCreate(0, name, OBJ_ARROW_RIGHT_PRICE, 0, time, price))
     {
      ObjectMove(0, name, 0, time, price);
      return(false);
     }

//--- make the label size adaptive
   long scale=2;
   if(!ChartGetInteger(0, CHART_SCALE, 0, scale))
     {
      //--- output an error message to the Experts journal
      Print(__FUNCTION__+", ChartGetInteger(CHART_SCALE) failed, error = ", GetLastError());
     }
   int width=scale>1 ? 2:1;  // if chart scale > 1, then label size = 2

   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name, OBJPROP_ZORDER, 0);

   return(true);
  }
//+------------------------------------------------------------------+
