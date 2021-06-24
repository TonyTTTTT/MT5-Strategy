//+------------------------------------------------------------------+
//|                                                         test.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   int total = PositionsTotal();
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
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
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
      else
      {
         request.price = SymbolInfoDouble(position_symbol, SYMBOL_ASK);
         request.type = ORDER_TYPE_BUY;    
      }
      PrintFormat("Close #%I64d %s %s",position_ticket,position_symbol,EnumToString(type));
      if(!OrderSend(request, result))
         PrintFormat("OrderSend error %d", GetLastError());
      
      PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);   
        
   }
   ZeroMemory(request);
   ZeroMemory(result);
   string target = "EURUSD";
   double price_trend = SymbolInfoDouble(target, SYMBOL_PRICE_CHANGE);
   Print("Current price compare to Yesterday's close: ", price_trend);
   MqlTradeCheckResult ch_result = {0};
   request.action = TRADE_ACTION_DEAL;
   request.symbol = target;
   request.volume = 0.1;
   request.type = ORDER_TYPE_BUY;
   request.price = SymbolInfoDouble(target, SYMBOL_ASK);
   request.deviation = 5;
   request.magic = 17236;
   if(price_trend > 0)
   {
      if(OrderCheck(request, ch_result))
      {
         Print("Enough money!");
      }
      else
      {
         Print("Can't buy, no enough money!");
         PrintFormat("OrderSend error %d", GetLastError());
      }
      if(!OrderSend(request, result))
      {
         PrintFormat("OrderSend error %d", GetLastError());
         Print("retcode: ", result.retcode);
      }
      else
      {
         Print("Sucess Buy!");
      }  
      PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
   }
   else if(price_trend < 0)
   {
      request.type = ORDER_TYPE_SELL;
      request.price = SymbolInfoDouble(target, SYMBOL_BID);
      if(OrderCheck(request, ch_result))
      {
         Print("Enough money!");
      }
      else
      {
         Print("Can't sell, no enough money!");
         PrintFormat("OrderSend error %d", GetLastError());
      }
      if(!OrderSend(request, result))
      {
         PrintFormat("OrderSend error %d", GetLastError());
         Print("retcode: ", result.retcode);
      }
      else
      {
         Print("Sucess Sell!");
      }  
      PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);      
   }
  }
//+------------------------------------------------------------------+
