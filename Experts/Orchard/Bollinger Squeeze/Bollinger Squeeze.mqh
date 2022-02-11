/*
 * Bollinger Squeeze.mqh
 *
 * Copyright 2022, Orchard Forex
 * https://orchardforex.com
 *
 */

/**=
 *
 * Disclaimer and Licence
 *
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * All trading involves risk. You should have received the risk warnings
 * and terms of use in the README.MD file distributed with this software.
 * See the README.MD file for more information and before using this software.
 *
 **/

#define APP_COPYRIGHT "Copyright 2022, Orchard Forex"
#define APP_LINK      "https://orchardforex.com"
#define APP_VERSION   "1.00"
#define APP_DESCRIPTION                                                                            \
   "A simple breakout expert based on\n"                                                           \
   "trading after Bollinger has entered\n"                                                         \
   "a tight range"
#define APP_COMMENT "Bollinger Squeeze"
#define APP_MAGIC   222222

#include "Framework.mqh"

//	Inputs

//	BBand specification
input int                InpBandsPeriod       = 20;          //	Bands period
input double             InpBandsDeviation    = 2.0;         //	Bands deviation
input ENUM_APPLIED_PRICE InpBandsAppliedPrice = PRICE_CLOSE; //	Bands applied price

//	Consolidation specification
input int InpSqueezePeriod   = 10;  //	Squeeze period
input int InpSqueezeRangePts = 200; //	Squeeze range in points

//	Default inputs
//	I have these in a separate file because I use them all the time
#include "Default Inputs.mqh"

//	The expert does all the work
#include "Expert.mqh"
CExpert *Expert;

//
int OnInit() {

   Expert = new CExpert( InpBandsPeriod, InpBandsDeviation,
                         InpBandsAppliedPrice,                 //	Bands
                         InpSqueezePeriod, InpSqueezeRangePts, //	Squeeze
                         InpVolume, InpTradeComment, InpMagic  //	Common
   );

   return ( Expert.OnInit() );
}

//
void OnDeinit( const int reason ) {

   delete Expert;
}

//
void OnTick() {

   Expert.OnTick();
}

//
