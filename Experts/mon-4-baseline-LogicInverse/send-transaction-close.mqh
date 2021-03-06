//+------------------------------------------------------------------+
//|                                             send-transaction.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#include "MACalculator.mqh"
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
input ulong magic_param = 17236;
input ushort reorder_try_param = 1;
input double volume_param = 1;
input ushort deviation_param = 5;
input ushort tp_point_param = 3000;
input ushort sl_point_param = 3000;
input ENUM_ORDER_TYPE_FILLING filling_type_param = ORDER_FILLING_IOC;

class OrderSender
{
   public:
      // constructor
      void OrderSender()
      {
         deviation = deviation_param;
         reorder_try = reorder_try_param;
         volume = volume_param;
         magic = magic_param;
         tp_point = tp_point_param;
         sl_point = sl_point_param;
      }
      
   private:
      int deviation;
      ushort reorder_try;
      double volume;
      ulong magic;
      ushort tp_point;
      ushort sl_point;
   private:
      MqlTradeRequest setOrderRequest(ENUM_ORDER_TYPE type, ENUM_SYMBOL_INFO_DOUBLE price_type)
      {
         MqlTradeRequest request = {};
         request.action = TRADE_ACTION_DEAL;
         request.symbol = _Symbol;
         request.volume = volume;
         request.type = type;
         request.type_filling = filling_type_param;
         request.price = SymbolInfoDouble(_Symbol, price_type);
         request.deviation = deviation;
         request.magic = magic;
         double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
         int    digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
         if(type == ORDER_TYPE_BUY)
         {
            request.tp = NormalizeDouble(request.price + tp_point * point, digits);
            request.sl = NormalizeDouble(request.price - sl_point * point, digits);
         }
         else // type == ORDER_TYPE_SELL
         {
            request.tp = NormalizeDouble(request.price - tp_point * point, digits);
            request.sl = NormalizeDouble(request.price + sl_point * point, digits);           
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
               else if(price_type == SYMBOL_ASK)
               {
                  PrintFormat("Sucess Buy!\nretcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
                  break;
               }
               else if(price_type == SYMBOL_BID)
               {
                  PrintFormat("Sucess Sell!\nretcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
                  break;
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
            if(price_type == SYMBOL_ASK)
            {
               PrintFormat("Sucess Buy!\nretcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
            }
            else if(price_type == SYMBOL_BID)
            {
               PrintFormat("Sucess Sell!\nretcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
            } 
         }
      }
  
      double getMA()
      {
         MACalculator ma_calculator();
         double ma = ma_calculator.getSimpleMA();
         PrintFormat("MA: %f", ma);
         return ma;
      }
      int getPositionTotal()
      {
         int total = PositionsTotal();
         PrintFormat("total: %d", total);
         
         return total;
      }
      
   public:
      // type_int = 0 -> no position
      // type_int = 1 -> POSITION_TYPE_BUY
      // type_int = 2 -> POSITION_TYPE_SELL
      int closePosition(ENUM_POSITION_TYPE tg_type)
      {
         int type_int = 0;
         int total = PositionsTotal();
         Print("total: ", total);
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
         int postion_total = getPositionTotal();
         
         if(postion_total == 0)
         {
            double ma = getMA();
            
            if(SymbolInfoDouble(_Symbol, SYMBOL_ASK) < ma || ma == -2)
            {
               PrintFormat("Buying: %s", _Symbol);
               string target = _Symbol;
               MqlTradeRequest request = setOrderRequest(ORDER_TYPE_BUY, SYMBOL_ASK);
               MqlTradeResult result = {};
               sendingOrder(request, result, SYMBOL_ASK);
            }   
            else if(ma == -1)
               Print("error occur when get ma, don't order");
            else
               Print("current buy price > MA, don't buy");
          }
          else // postion_total != 0
            Print("There is position, don't order");   
      }
      
      
      void sell()
      {
         int postion_total = getPositionTotal();
         
         if(postion_total == 0)
         {
            double ma = getMA();
            if(SymbolInfoDouble(_Symbol, SYMBOL_BID) > ma || ma == -2)
            {    
               PrintFormat("Selling: %s", _Symbol);
               MqlTradeRequest request = setOrderRequest(ORDER_TYPE_SELL, SYMBOL_BID);
               MqlTradeResult result = {};
               sendingOrder(request, result, SYMBOL_BID);
            }
            else if(ma == -1)
               Print("error occur when get ma, don't order");
            else
               Print("current sell price < MA, don't sell");
         }
         else // postion_total != 0
            Print("There is position, don't order");   
      }
};