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
int deviation = 1000;
int try = 5;
ENUM_POSITION_TYPE closePosition(ENUM_POSITION_TYPE tg_type)
{
   int total = PositionsTotal();
   ENUM_POSITION_TYPE type = NULL;
   if(total == 0)
      return type;
   Print("total: ", total);
   MqlTradeRequest request;
   MqlTradeResult result;
   for(int i = total-1; i>=0; i--)
   {
      ulong position_ticket=PositionGetTicket(i);
      string position_symbol = PositionGetString(POSITION_SYMBOL);
      int digits = (int)SymbolInfoInteger(position_symbol, SYMBOL_DIGITS);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      double volume = PositionGetDouble(POSITION_VOLUME);
      double sl = PositionGetDouble(POSITION_SL);
      double tp = PositionGetDouble(POSITION_TP);
      type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      PrintFormat("#%I64u %s  %s  volume: %.2f  price: %s  sl: %s  tp: %s  [%I64d]",
                  position_ticket,
                  position_symbol,
                  EnumToString(type),
                  volume,
                  DoubleToString(PositionGetDouble(POSITION_PRICE_OPEN),digits),
                  DoubleToString(sl,digits),
                  DoubleToString(tp,digits),
                  magic);
      ZeroMemory(request);
      ZeroMemory(result);
      request.action = TRADE_ACTION_DEAL;
      request.position = position_ticket;
      request.symbol = position_symbol;
      request.volume = volume;
      request.deviation = 5;
      request.magic = magic;
      request.position_by = PositionGetInteger(POSITION_TICKET);
      request.magic = magic;
      if(type == POSITION_TYPE_BUY)
      {
         request.price = SymbolInfoDouble(position_symbol, SYMBOL_BID);
         request.type = ORDER_TYPE_SELL;
      }
      else if(type == POSITION_TYPE_SELL)
      {
         request.price = SymbolInfoDouble(position_symbol, SYMBOL_ASK);
         request.type = ORDER_TYPE_BUY;    
      }
      
      if(type == tg_type)
      {
         PrintFormat("Close #%I64d %s %s",position_ticket,position_symbol,EnumToString(type));
         for(int j=0; j<try; j++)
         {
            if(!OrderSend(request, result))
            {
               PrintFormat("OrderSend error %d", GetLastError());
               Print("retcode: ", result.retcode);
               if(request.type == ORDER_TYPE_SELL)
                  request.price = SymbolInfoDouble(position_symbol, SYMBOL_BID);
               else if(request.type == ORDER_TYPE_BUY)
                  request.price = SymbolInfoDouble(position_symbol, SYMBOL_ASK);
            }
            else
            {
               PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);   
               break;
            }   
         }
         /*while(!OrderSend(request, result))
         {
            PrintFormat("OrderSend error %d", GetLastError());
            Print("retcode: ", result.retcode);
            if(request.type == ORDER_TYPE_SELL)
               request.price = SymbolInfoDouble(position_symbol, SYMBOL_BID);
            else if(request.type == ORDER_TYPE_BUY)
               request.price = SymbolInfoDouble(position_symbol, SYMBOL_ASK);
         }
         PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order); */
      }
   }
   return type; 
}


void buy()
{
   ENUM_POSITION_TYPE type = closePosition(POSITION_TYPE_SELL);
   if(type != POSITION_TYPE_BUY)
   {
      PrintFormat("Buying: %s", _Symbol);
      string target = _Symbol;
      MqlTradeRequest request = {};
      MqlTradeResult result = {};
      MqlTradeCheckResult ch_result = {0};
      request.action = TRADE_ACTION_DEAL;
      request.symbol = target;
      request.volume = 1;
      request.type = ORDER_TYPE_BUY;
      request.type_filling = ORDER_FILLING_IOC;
      request.price = SymbolInfoDouble(target, SYMBOL_ASK);
      request.deviation = deviation;
      request.magic = 17236;
      if(OrderCheck(request, ch_result))
      {
         Print("Enough money!");
      }
      else
      {
         Print("Can't buy, no enough money!");
         PrintFormat("OrderSend error %d", GetLastError());
      }
      
      for(int j=0; j<try; j++)
      {
         if(!OrderSend(request, result))
         {
            PrintFormat("OrderSend error %d", GetLastError());
            Print("retcode: ", result.retcode);
            request.price = SymbolInfoDouble(target, SYMBOL_ASK);
         }
         else
         {
            PrintFormat("Sucess Buy!\nretcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
            break;
         }   
      }
      /*while(!OrderSend(request, result))
      {
         PrintFormat("OrderSend error %d", GetLastError());
         Print("retcode: ", result.retcode);
         request.price = SymbolInfoDouble(target, SYMBOL_ASK);
      }
      PrintFormat("Sucess Buy!\nretcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);*/
    }
    else
      PrintFormat("Trend same, do nothing in this peroid!");
}


void sell()
{
   ENUM_POSITION_TYPE type = closePosition(POSITION_TYPE_BUY);
   if(type != POSITION_TYPE_SELL)
   {
      PrintFormat("Selling: %s", _Symbol);
      string target = _Symbol;
      MqlTradeRequest request = {};
      MqlTradeResult result = {};
      MqlTradeCheckResult ch_result = {0};
      request.action = TRADE_ACTION_DEAL;
      request.symbol = target;
      request.volume = 1;
      request.type = ORDER_TYPE_SELL;
      request.type_filling = ORDER_FILLING_IOC;
      request.price = SymbolInfoDouble(target, SYMBOL_BID);
      request.deviation = deviation;
      request.magic = 17236;
      if(OrderCheck(request, ch_result))
      {
         Print("Enough money!");
      }
      else
      {
         Print("Can't buy, no enough money!");
         PrintFormat("OrderSend error %d", GetLastError());
      }
      
      for(int j=0; j<try; j++)
      {
         if(!OrderSend(request, result))
         {
            PrintFormat("OrderSend error %d", GetLastError());
            Print("retcode: ", result.retcode);
            request.price = SymbolInfoDouble(target, SYMBOL_BID);
         }
         else
         {
            PrintFormat("Sucess Sell!\nretcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
            break;
         }   
      }
      /*while(!OrderSend(request, result))
      {
         PrintFormat("OrderSend error %d", GetLastError());
         Print("retcode: ", result.retcode);
         request.price = SymbolInfoDouble(target, SYMBOL_BID);
      }
      PrintFormat("Sucess Sell!\nretcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);*/
   }
   else
      PrintFormat("Trend same, do nothing in this peroid!");
}