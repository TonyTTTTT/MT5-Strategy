//+------------------------------------------------------------------+
//|                                             send-transaction.mqh |
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

// buy -> ASK
// sell -> BID

class OrderSender
{
   public:
      // constructor
      void OrderSender(ushort reorder_try_param, datetime start_time_param)
      {
         deviation = 5;
         reorder_try = reorder_try_param;
         volume = 1;
         magic = 17236;
         profit_offset = 1000;
         start_time = start_time_param;
      }
      
   private:
      int deviation;
      ushort reorder_try;
      double volume;
      ulong magic;
      ushort profit_offset;
      datetime start_time;
   private:
      MqlTradeRequest setOrderRequest(ENUM_ORDER_TYPE type, ENUM_SYMBOL_INFO_DOUBLE price_type)
      {
         MqlTradeRequest request = {};
         request.action = TRADE_ACTION_DEAL;
         request.symbol = _Symbol;
         request.volume = volume;
         request.type = type;
         request.type_filling = ORDER_FILLING_IOC;
         request.price = SymbolInfoDouble(_Symbol, price_type);
         request.deviation = deviation;
         request.magic = magic;
         double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
         int    digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
         if(type == ORDER_TYPE_BUY)
         {
            request.tp = NormalizeDouble(request.price + profit_offset * point, digits);
            request.sl = NormalizeDouble(request.price - profit_offset * point, digits);
         }
         else // type == ORDER_TYPE_SELL
         {
            request.tp = NormalizeDouble(request.price - profit_offset * point, digits);
            request.sl = NormalizeDouble(request.price + profit_offset * point, digits);           
         }   
         PrintFormat("price: %f, tp: %f, sl: %f",
                     request.price, request.tp, request.sl);
         
         return request;
      }
      
      MqlTradeRequest setCloseRequest(ulong ticket_pos, string symbol_pos, double volume_pos)
      {
         MqlTradeRequest request = {};
         request.action = TRADE_ACTION_DEAL;
         request.position = ticket_pos;
         request.symbol = symbol_pos;
         request.volume = volume_pos;
         request.deviation = deviation;
         request.magic = magic;
         
         return request;
      }
      
      void sendingOrder(MqlTradeRequest &request, MqlTradeResult &result, ENUM_SYMBOL_INFO_DOUBLE price_type)
      {
         if(reorder_try < 65535)
         {
            for(int i=0; i<reorder_try; i++)
            {
               if(!OrderSend(request, result))
               {
                  PrintFormat("OrderSend error: %d, retcode: %d", GetLastError(), result.retcode);
                  request.price = SymbolInfoDouble(_Symbol, price_type);
               }
               else
               {
                  if(price_type == SYMBOL_ASK)
                  {
                     PrintFormat("Sucess Buy! retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
                     break;
                  }
                  else //price_type == SYMBOL_BID
                  {
                     PrintFormat("Sucess Sell! retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
                     break; 
                  }   
               }   
            }
         }
         else // reorder_try == 65535
         {   
            while(!OrderSend(request, result))
            {
               PrintFormat("OrderSend error: %d, retcode: %d", GetLastError(), result.retcode);
               request.price = SymbolInfoDouble(_Symbol, price_type);
            }
            PrintFormat("Sucess Buy!\nretcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
         }
      }

   string getOrderType(long type) 
     { 
      string str_type="unknown operation"; 
      switch(type) 
        { 
         case (ORDER_TYPE_BUY):            return("buy"); 
         case (ORDER_TYPE_SELL):           return("sell"); 
         case (ORDER_TYPE_BUY_LIMIT):      return("buy limit"); 
         case (ORDER_TYPE_SELL_LIMIT):     return("sell limit"); 
         case (ORDER_TYPE_BUY_STOP):       return("buy stop"); 
         case (ORDER_TYPE_SELL_STOP):      return("sell stop"); 
         case (ORDER_TYPE_BUY_STOP_LIMIT): return("buy stop limit"); 
         case (ORDER_TYPE_SELL_STOP_LIMIT):return("sell stop limit"); 
        } 
      return(str_type); 
     }

      string getLastOrderType()
      {
         datetime now_time = TimeCurrent();
         PrintFormat("start_time: %s", TimeToString(start_time));
         PrintFormat("now_time: %s", TimeToString(now_time));
         datetime end = __DATETIME__;
         bool suc_get_his_ord = HistorySelect(start_time, now_time);
         string type_order = "null";
         if(suc_get_his_ord)
         {
            int orders_total = HistoryOrdersTotal();
            PrintFormat("There is %d orders in history", orders_total);
            if(orders_total > 0)
            {
               ulong ticket_order = HistoryOrderGetTicket(orders_total-2);
               type_order = getOrderType(HistoryOrderGetInteger(ticket_order, ORDER_TYPE));
            
               /*for(int i = orders_total-1; i>=0; i--)
               {
                  ticket_deal = HistoryOrderGetTicket(i);
                  type_deal = getOrderType(HistoryOrderGetInteger(ticket_deal, ORDER_TYPE));
                  PrintFormat("order: %d, type: %s", i, type_deal);
               }*/
            }
         }
         else
            PrintFormat("Fail to get history");   
         
         
         return type_order;
      }
      
   public:
      // type_int = 0 -> no position
      // type_int = 1 -> POSITION_TYPE_BUY
      // type_int = 2 -> POSITION_TYPE_SELL
      int closePosition(ENUM_POSITION_TYPE tg_type)
      {
         int type_int = 0;
         int total = PositionsTotal();
         Print("opening deals total: ", total);
         if(total == 0)
            return type_int;
         
         for(int i = total-1; i>=0; i--)
         {
            ulong ticket_pos=PositionGetTicket(i);
            string symbol_pos = PositionGetString(POSITION_SYMBOL);
            int digits = (int)SymbolInfoInteger(symbol_pos, SYMBOL_DIGITS);
            ulong magic_pos = PositionGetInteger(POSITION_MAGIC);
            double volume_pos = PositionGetDouble(POSITION_VOLUME);
            double sl_pos = PositionGetDouble(POSITION_SL);
            double tp_pos = PositionGetDouble(POSITION_TP);
            ENUM_POSITION_TYPE type_pos = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            PrintFormat("#%I64u %s  %s  volume: %.2f  price: %s  sl: %s  tp: %s  [%I64d]",
                        ticket_pos,
                        symbol_pos,
                        EnumToString(type_pos),
                        volume_pos,
                        DoubleToString(PositionGetDouble(POSITION_PRICE_OPEN),digits),
                        DoubleToString(sl_pos,digits),
                        DoubleToString(tp_pos,digits),
                        magic_pos);

            MqlTradeRequest request = setCloseRequest(ticket_pos, symbol_pos, volume_pos);
            MqlTradeResult result = {};

            if(type_pos == POSITION_TYPE_BUY)
            {
               type_int = 1;
               request.price = SymbolInfoDouble(symbol_pos, SYMBOL_BID);
               request.type = ORDER_TYPE_SELL;
            }
            else if(type_pos == POSITION_TYPE_SELL)
            {
               type_int = 2;
               request.price = SymbolInfoDouble(symbol_pos, SYMBOL_ASK);
               request.type = ORDER_TYPE_BUY;    
            }
            
            if(type_pos == tg_type)
            {
               PrintFormat("Closing #%I64d %s %s : ",ticket_pos, symbol_pos, EnumToString(type_pos));
               if(request.type == ORDER_TYPE_BUY)
                  sendingOrder(request, result, SYMBOL_ASK);
               else if(request.type == ORDER_TYPE_SELL)
                  sendingOrder(request, result, SYMBOL_BID);
            }
         }
         return type_int; 
      }
      
      
      void buy()
      {
         int type_int = closePosition(POSITION_TYPE_SELL);
         
         if(type_int == 0)
         {
            string last_type = getLastOrderType();
            PrintFormat("last_type: %s", last_type);
            if(last_type == "sell" || last_type == "null")
            {
               //Print("last deal type: ", type_last_deal);
               PrintFormat("Buying: %s", _Symbol);
               string target = _Symbol;
               MqlTradeRequest request = setOrderRequest(ORDER_TYPE_BUY, SYMBOL_ASK);
               MqlTradeResult result = {};
               sendingOrder(request, result, SYMBOL_ASK);
            }
            else
               PrintFormat("Already tp or sl in same trend(Buy), do nothing in this peroid!");
          }
          else if(type_int == 1)
            PrintFormat("Trend same(Buy), and there is opening position, do nothing in this peroid!");
          else if(type_int == 2)
            PrintFormat("Close the sell position!");   
      }
      
      
      void sell()
      {
         int type_int = closePosition(POSITION_TYPE_BUY);
         
         if(type_int == 0)
         {
            string last_type = getLastOrderType();
            if(last_type == "buy" || last_type == "null")
            {
               //Print("last deal type: ", type_last_deal);
               PrintFormat("Selling: %s", _Symbol);
               MqlTradeRequest request = setOrderRequest(ORDER_TYPE_SELL, SYMBOL_BID);
               MqlTradeResult result = {};
               sendingOrder(request, result, SYMBOL_BID);
            }
            else
               PrintFormat("Already tp or sl in same trend(Sell), do nothing in this peroid!");
         }
         else if(type_int == 2)
            PrintFormat("Trend same(Sell), and there is opening postion, do nothing in this peroid!");
         else if(type_int == 1)
            PrintFormat("Close the buy position!");
      }
};