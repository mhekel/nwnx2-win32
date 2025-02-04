MOD V1.0           �   �   h  h   h  ����                                                                                                                    aps_include         �  area001            �  area001            �  area001            �  creaturepalcus     �  doorpalcus         �  encounterpalcus    �  hashset_nwnx       �  itempalcus         �  modload         	   �  modload         
     modload            �  placeablepalcus    �  Repute             �  soundpalcus        �  storepalcus        �  triggerpalcus      �  waypointpalcus     �  module             �     �E  �H  i2  b{  �  �|  �  �  �  ��  �  b�  �  
�  �  ��  <  �  �  m�    n�  �  ]�  �  Y�  a  �  �  � �  z l  � �  �
 &  // Name     : Avlis Persistence System include
// Purpose  : Various APS/NWNX2 related functions
// Authors  : Ingmar Stieger, Adam Colon, Josh Simon
// Modified : December 21, 2003

// This file is licensed under the terms of the
// GNU GENERAL PUBLIC LICENSE (GPL) Version 2

/************************************/
/* Return codes                     */
/************************************/

int SQL_ERROR = 0;
int SQL_SUCCESS = 1;

/************************************/
/* Function prototypes              */
/************************************/

// Setup placeholders for ODBC requests and responses
void SQLInit();

// Execute statement in sSQL
void SQLExecDirect(string sSQL);

// Position cursor on next row of the resultset
// Call this before using SQLGetData().
// returns: SQL_SUCCESS if there is a row
//          SQL_ERROR if there are no more rows
int SQLFetch();

// * deprecated. Use SQLFetch instead.
// Position cursor on first row of the resultset and name it sResultSetName
// Call this before using SQLNextRow() and SQLGetData().
// returns: SQL_SUCCESS if result set is not empty
//          SQL_ERROR is result set is empty
int SQLFirstRow();

// * deprecated. Use SQLFetch instead.
// Position cursor on next row of the result set sResultSetName
// returns: SQL_SUCCESS if cursor could be advanced to next row
//          SQL_ERROR if there was no next row
int SQLNextRow();

// Return value of column iCol in the current row of result set sResultSetName
string SQLGetData(int iCol);

// Return a string value when given a location
string APSLocationToString(location lLocation);

// Return a location value when given the string form of the location
location APSStringToLocation(string sLocation);

// Return a string value when given a vector
string APSVectorToString(vector vVector);

// Return a vector value when given the string form of the vector
vector APSStringToVector(string sVector);

// Set oObject's persistent string variable sVarName to sValue
// Optional parameters:
//   iExpiration: Number of days the persistent variable should be kept in database (default: 0=forever)
//   sTable: Name of the table where variable should be stored (default: pwdata)
void SetPersistentString(object oObject, string sVarName, string sValue, int iExpiration =
                         0, string sTable = "pwdata");

// Set oObject's persistent integer variable sVarName to iValue
// Optional parameters:
//   iExpiration: Number of days the persistent variable should be kept in database (default: 0=forever)
//   sTable: Name of the table where variable should be stored (default: pwdata)
void SetPersistentInt(object oObject, string sVarName, int iValue, int iExpiration =
                      0, string sTable = "pwdata");

// Set oObject's persistent float variable sVarName to fValue
// Optional parameters:
//   iExpiration: Number of days the persistent variable should be kept in database (default: 0=forever)
//   sTable: Name of the table where variable should be stored (default: pwdata)
void SetPersistentFloat(object oObject, string sVarName, float fValue, int iExpiration =
                        0, string sTable = "pwdata");

// Set oObject's persistent location variable sVarName to lLocation
// Optional parameters:
//   iExpiration: Number of days the persistent variable should be kept in database (default: 0=forever)
//   sTable: Name of the table where variable should be stored (default: pwdata)
//   This function converts location to a string for storage in the database.
void SetPersistentLocation(object oObject, string sVarName, location lLocation, int iExpiration =
                           0, string sTable = "pwdata");

// Set oObject's persistent vector variable sVarName to vVector
// Optional parameters:
//   iExpiration: Number of days the persistent variable should be kept in database (default: 0=forever)
//   sTable: Name of the table where variable should be stored (default: pwdata)
//   This function converts vector to a string for storage in the database.
void SetPersistentVector(object oObject, string sVarName, vector vVector, int iExpiration =
                         0, string sTable = "pwdata");

// Get oObject's persistent string variable sVarName
// Optional parameters:
//   sTable: Name of the table where variable is stored (default: pwdata)
// * Return value on error: ""
string GetPersistentString(object oObject, string sVarName, string sTable = "pwdata");

// Get oObject's persistent integer variable sVarName
// Optional parameters:
//   sTable: Name of the table where variable is stored (default: pwdata)
// * Return value on error: 0
int GetPersistentInt(object oObject, string sVarName, string sTable = "pwdata");

// Get oObject's persistent float variable sVarName
// Optional parameters:
//   sTable: Name of the table where variable is stored (default: pwdata)
// * Return value on error: 0
float GetPersistentFloat(object oObject, string sVarName, string sTable = "pwdata");

// Get oObject's persistent location variable sVarName
// Optional parameters:
//   sTable: Name of the table where variable is stored (default: pwdata)
// * Return value on error: 0
location GetPersistentLocation(object oObject, string sVarname, string sTable = "pwdata");

// Get oObject's persistent vector variable sVarName
// Optional parameters:
//   sTable: Name of the table where variable is stored (default: pwdata)
// * Return value on error: 0
vector GetPersistentVector(object oObject, string sVarName, string sTable = "pwdata");

// Delete persistent variable sVarName stored on oObject
// Optional parameters:
//   sTable: Name of the table where variable is stored (default: pwdata)
void DeletePersistentVariable(object oObject, string sVarName, string sTable = "pwdata");

// (private function) Replace special character ' with ~
string SQLEncodeSpecialChars(string sString);

// (private function)Replace special character ' with ~
string SQLDecodeSpecialChars(string sString);

/************************************/
/* Implementation                   */
/************************************/

// Functions for initializing APS and working with result sets

void SQLInit()
{
    int i;

    // Placeholder for ODBC persistence
    string sMemory;

    for (i = 0; i < 8; i++)     // reserve 8*128 bytes
        sMemory +=
            "................................................................................................................................";

    SetLocalString(GetModule(), "NWNX!ODBC!SPACER", sMemory);
}

void SQLExecDirect(string sSQL)
{
    SetLocalString(GetModule(), "NWNX!ODBC!EXEC", sSQL);
}

int SQLFetch()
{
    string sRow;
    object oModule = GetModule();

    SetLocalString(oModule, "NWNX!ODBC!FETCH", GetLocalString(oModule, "NWNX!ODBC!SPACER"));
    sRow = GetLocalString(oModule, "NWNX!ODBC!FETCH");
    if (GetStringLength(sRow) > 0)
    {
        SetLocalString(oModule, "NWNX_ODBC_CurrentRow", sRow);
        return SQL_SUCCESS;
    }
    else
    {
        SetLocalString(oModule, "NWNX_ODBC_CurrentRow", "");
        return SQL_ERROR;
    }
}

// deprecated. use SQLFetch().
int SQLFirstRow()
{
    return SQLFetch();
}

// deprecated. use SQLFetch().
int SQLNextRow()
{
    return SQLFetch();
}

string SQLGetData(int iCol)
{
    int iPos;
    string sResultSet = GetLocalString(GetModule(), "NWNX_ODBC_CurrentRow");

    // find column in current row
    int iCount = 0;
    string sColValue = "";

    iPos = FindSubString(sResultSet, "�");
    if ((iPos == -1) && (iCol == 1))
    {
        // only one column, return value immediately
        sColValue = sResultSet;
    }
    else if (iPos == -1)
    {
        // only one column but requested column > 1
        sColValue = "";
    }
    else
    {
        // loop through columns until found
        while (iCount != iCol)
        {
            iCount++;
            if (iCount == iCol)
                sColValue = GetStringLeft(sResultSet, iPos);
            else
            {
                sResultSet = GetStringRight(sResultSet, GetStringLength(sResultSet) - iPos - 1);
                iPos = FindSubString(sResultSet, "�");
            }

            // special case: last column in row
            if (iPos == -1)
                iPos = GetStringLength(sResultSet);
        }
    }

    return sColValue;
}

// These functions deal with various data types. Ultimately, all information
// must be stored in the database as strings, and converted back to the proper
// form when retrieved.

string APSVectorToString(vector vVector)
{
    return "#POSITION_X#" + FloatToString(vVector.x) + "#POSITION_Y#" + FloatToString(vVector.y) +
        "#POSITION_Z#" + FloatToString(vVector.z) + "#END#";
}

vector APSStringToVector(string sVector)
{
    float fX, fY, fZ;
    int iPos, iCount;
    int iLen = GetStringLength(sVector);

    if (iLen > 0)
    {
        iPos = FindSubString(sVector, "#POSITION_X#") + 12;
        iCount = FindSubString(GetSubString(sVector, iPos, iLen - iPos), "#");
        fX = StringToFloat(GetSubString(sVector, iPos, iCount));

        iPos = FindSubString(sVector, "#POSITION_Y#") + 12;
        iCount = FindSubString(GetSubString(sVector, iPos, iLen - iPos), "#");
        fY = StringToFloat(GetSubString(sVector, iPos, iCount));

        iPos = FindSubString(sVector, "#POSITION_Z#") + 12;
        iCount = FindSubString(GetSubString(sVector, iPos, iLen - iPos), "#");
        fZ = StringToFloat(GetSubString(sVector, iPos, iCount));
    }

    return Vector(fX, fY, fZ);
}

string APSLocationToString(location lLocation)
{
    object oArea = GetAreaFromLocation(lLocation);
    vector vPosition = GetPositionFromLocation(lLocation);
    float fOrientation = GetFacingFromLocation(lLocation);
    string sReturnValue;

    if (GetIsObjectValid(oArea))
        sReturnValue =
            "#AREA#" + GetTag(oArea) + "#POSITION_X#" + FloatToString(vPosition.x) +
            "#POSITION_Y#" + FloatToString(vPosition.y) + "#POSITION_Z#" +
            FloatToString(vPosition.z) + "#ORIENTATION#" + FloatToString(fOrientation) + "#END#";

    return sReturnValue;
}

location APSStringToLocation(string sLocation)
{
    location lReturnValue;
    object oArea;
    vector vPosition;
    float fOrientation, fX, fY, fZ;

    int iPos, iCount;
    int iLen = GetStringLength(sLocation);

    if (iLen > 0)
    {
        iPos = FindSubString(sLocation, "#AREA#") + 6;
        iCount = FindSubString(GetSubString(sLocation, iPos, iLen - iPos), "#");
        oArea = GetObjectByTag(GetSubString(sLocation, iPos, iCount));

        iPos = FindSubString(sLocation, "#POSITION_X#") + 12;
        iCount = FindSubString(GetSubString(sLocation, iPos, iLen - iPos), "#");
        fX = StringToFloat(GetSubString(sLocation, iPos, iCount));

        iPos = FindSubString(sLocation, "#POSITION_Y#") + 12;
        iCount = FindSubString(GetSubString(sLocation, iPos, iLen - iPos), "#");
        fY = StringToFloat(GetSubString(sLocation, iPos, iCount));

        iPos = FindSubString(sLocation, "#POSITION_Z#") + 12;
        iCount = FindSubString(GetSubString(sLocation, iPos, iLen - iPos), "#");
        fZ = StringToFloat(GetSubString(sLocation, iPos, iCount));

        vPosition = Vector(fX, fY, fZ);

        iPos = FindSubString(sLocation, "#ORIENTATION#") + 13;
        iCount = FindSubString(GetSubString(sLocation, iPos, iLen - iPos), "#");
        fOrientation = StringToFloat(GetSubString(sLocation, iPos, iCount));

        lReturnValue = Location(oArea, vPosition, fOrientation);
    }

    return lReturnValue;
}

// These functions are responsible for transporting the various data types back
// and forth to the database.

void SetPersistentString(object oObject, string sVarName, string sValue, int iExpiration =
                         0, string sTable = "pwdata")
{
    string sPlayer;
    string sTag;

    if (GetIsPC(oObject))
    {
        sPlayer = SQLEncodeSpecialChars(GetPCPlayerName(oObject));
        sTag = SQLEncodeSpecialChars(GetName(oObject));
    }
    else
    {
        sPlayer = "~";
        sTag = GetTag(oObject);
    }

    sVarName = SQLEncodeSpecialChars(sVarName);
    sValue = SQLEncodeSpecialChars(sValue);

    string sSQL = "SELECT player FROM " + sTable + " WHERE player='" + sPlayer +
        "' AND tag='" + sTag + "' AND name='" + sVarName + "'";
    SQLExecDirect(sSQL);

    if (SQLFirstRow() == SQL_SUCCESS)
    {
        // row exists
        sSQL = "UPDATE " + sTable + " SET val='" + sValue +
            "',expire=" + IntToString(iExpiration) + " WHERE player='" + sPlayer +
            "' AND tag='" + sTag + "' AND name='" + sVarName + "'";
        SQLExecDirect(sSQL);
    }
    else
    {
        // row doesn't exist
        sSQL = "INSERT INTO " + sTable + " (player,tag,name,val,expire) VALUES" +
            "('" + sPlayer + "','" + sTag + "','" + sVarName + "','" +
            sValue + "'," + IntToString(iExpiration) + ")";
        SQLExecDirect(sSQL);
    }
}

string GetPersistentString(object oObject, string sVarName, string sTable = "pwdata")
{
    string sPlayer;
    string sTag;

    if (GetIsPC(oObject))
    {
        sPlayer = SQLEncodeSpecialChars(GetPCPlayerName(oObject));
        sTag = SQLEncodeSpecialChars(GetName(oObject));
    }
    else
    {
        sPlayer = "~";
        sTag = GetTag(oObject);
    }

    sVarName = SQLEncodeSpecialChars(sVarName);

    string sSQL = "SELECT val FROM " + sTable + " WHERE player='" + sPlayer +
        "' AND tag='" + sTag + "' AND name='" + sVarName + "'";
    SQLExecDirect(sSQL);

    if (SQLFirstRow() == SQL_SUCCESS)
        return SQLDecodeSpecialChars(SQLGetData(1));
    else
    {
        return "";
        // If you want to convert your existing persistent data to APS, this
        // would be the place to do it. The requested variable was not found
        // in the database, you should
        // 1) query it's value using your existing persistence functions
        // 2) save the value to the database using SetPersistentString()
        // 3) return the string value here.
    }
}

void SetPersistentInt(object oObject, string sVarName, int iValue, int iExpiration =
                      0, string sTable = "pwdata")
{
    SetPersistentString(oObject, sVarName, IntToString(iValue), iExpiration, sTable);
}

int GetPersistentInt(object oObject, string sVarName, string sTable = "pwdata")
{
    return StringToInt(GetPersistentString(oObject, sVarName, sTable));
}

void SetPersistentFloat(object oObject, string sVarName, float fValue, int iExpiration =
                        0, string sTable = "pwdata")
{
    SetPersistentString(oObject, sVarName, FloatToString(fValue), iExpiration, sTable);
}

float GetPersistentFloat(object oObject, string sVarName, string sTable = "pwdata")
{
    return StringToFloat(GetPersistentString(oObject, sVarName, sTable));
}

void SetPersistentLocation(object oObject, string sVarName, location lLocation, int iExpiration =
                           0, string sTable = "pwdata")
{
    SetPersistentString(oObject, sVarName, APSLocationToString(lLocation), iExpiration, sTable);
}

location GetPersistentLocation(object oObject, string sVarName, string sTable = "pwdata")
{
    return APSStringToLocation(GetPersistentString(oObject, sVarName, sTable));
}

void SetPersistentVector(object oObject, string sVarName, vector vVector, int iExpiration =
                         0, string sTable = "pwdata")
{
    SetPersistentString(oObject, sVarName, APSVectorToString(vVector), iExpiration, sTable);
}

vector GetPersistentVector(object oObject, string sVarName, string sTable = "pwdata")
{
    return APSStringToVector(GetPersistentString(oObject, sVarName, sTable));
}

void DeletePersistentVariable(object oObject, string sVarName, string sTable = "pwdata")
{
    string sPlayer;
    string sTag;

    if (GetIsPC(oObject))
    {
        sPlayer = SQLEncodeSpecialChars(GetPCPlayerName(oObject));
        sTag = SQLEncodeSpecialChars(GetName(oObject));
    }
    else
    {
        sPlayer = "~";
        sTag = GetTag(oObject);
    }

    sVarName = SQLEncodeSpecialChars(sVarName);
    string sSQL = "DELETE FROM " + sTable + " WHERE player='" + sPlayer +
        "' AND tag='" + sTag + "' AND name='" + sVarName + "'";
    SQLExecDirect(sSQL);
}

// Problems can arise with SQL commands if variables or values have single quotes
// in their names. These functions are a replace these quote with the tilde character

string SQLEncodeSpecialChars(string sString)
{
    if (FindSubString(sString, "'") == -1)      // not found
        return sString;

    int i;
    string sReturn = "";
    string sChar;

    // Loop over every character and replace special characters
    for (i = 0; i < GetStringLength(sString); i++)
    {
        sChar = GetSubString(sString, i, 1);
        if (sChar == "'")
            sReturn += "~";
        else
            sReturn += sChar;
    }
    return sReturn;
}

string SQLDecodeSpecialChars(string sString)
{
    if (FindSubString(sString, "~") == -1)      // not found
        return sString;

    int i;
    string sReturn = "";
    string sChar;

    // Loop over every character and replace special characters
    for (i = 0; i < GetStringLength(sString); i++)
    {
        sChar = GetSubString(sString, i, 1);
        if (sChar == "~")
            sReturn += "'";
        else
            sReturn += sChar;
    }
    return sReturn;
}

ARE V3.28   A   D  �  <#  4   |&  =   �&  �
  a1    ����    *      �   
      �   
      �   
         
      H  
      p  
      �  
      �  
      �  
        
      8  
      `  
      �  
      �  
      �  
         
      (  
      P  
      x  
      �  
      �  
      �  
        
      @  
      h  
      �  
      �  
      �  
        
      0  
      X  
      �  
      �  
      �  
      �  
         
      H  
      p  
      �  
      �  
      �  
        
      8  
      `  
      �  
      �  
      �  
         
      (  
      P  
      x  
      �  
      �  
      �  
      	  
      @	  
      h	  
      �	  
      �	  
      �	  
      
  
      0
  
      X
  
      �
  
          ����      ����         
                         '   
      /                         	          
                       dd�                  22d                 22d       ���                  h~�                                        2           4B                                                                                      !          "         #         $   3      %   4      &   5      '   6      (   7      )         *         +          ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +          ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +          ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +          ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +          ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +          ,           -           .           /           0           1          2          3         *         +          ,           -           .           /           0           1          2          3         *         +          ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +          ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +          ,           -           .           /           0           1          2          3         *         +          ,           -           .           /           0           1          2          3         *         +          ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +          ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +          ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +          ,           -           .           /           0           1          2          3         *         +          ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +          ,           -           .           /           0           1          2          3         *         +          ,           -           .           /           0           1          2          3         *         +          ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3         *         +          ,           -           .           /           0           1          2          3         *         +         ,           -           .           /           0           1          2          3      ID              Creator_ID      Version         Tag             Name            ResRef          Comments        Expansion_List  Flags           ModSpotCheck    ModListenCheck  MoonAmbientColorMoonDiffuseColorMoonFogAmount   MoonFogColor    MoonShadows     SunAmbientColor SunDiffuseColor SunFogAmount    SunFogColor     SunShadows      IsNight         LightingScheme  ShadowOpacity   FogClipDist     SkyBox          DayNightCycle   ChanceRain      ChanceSnow      ChanceLightning WindPower       LoadScreenID    PlayerVsPlayer  NoRest          Width           Height          OnEnter         OnExit          OnHeartbeat     OnUserDefined   Tileset         Tile_List       Tile_ID         Tile_OrientationTile_Height     Tile_MainLight1 Tile_MainLight2 Tile_SrcLight1  Tile_SrcLight2  Tile_AnimLoop1  Tile_AnimLoop2  Tile_AnimLoop3     Area001   ����          Area 001area001        tms01                            	   
                                                                      !   "   #   $   %   &   '   (   )   *   +   ,   -   .   /   0   1   2   3   4   5   6   7   8   9   :   ;   <   =   >   ?   @   A   B   C   D   E   F   G   H   I   J   K   L   M   N   O   P   Q   R   S   T   U   V   W   X   Y   Z   [   \   ]   ^   _   `   a   b   c   d   e   f   g   h   i   j   k   l   m   n   o   p   q   r   s   t   u   v   w   x   y   z   {   |   }   ~      �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �                      	  
                                               !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /  0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q  R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c  d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u  v  w  x  y  z  {  |  }  ~    �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �                     	  
                                               !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /  0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q  R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c  d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u  v  w  x  y  z  {  |  }  ~    �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �      @                           	   
                                                                      !   "   #   $   %   &   '   (   )   *   +   ,   -   .   /   0   1   2   3   4   5   6   7   8   9   :   ;   <   =   >   ?   @   GIC V3.28      D   	   �   	   @      @  $   d  $   ����    	                                                                                       Creature List   Door List       Encounter List  List            SoundList       StoreList       TriggerList     WaypointList    Placeable List                                                                  GIT V3.28      P      4     d      d  L   �  $   ����$   
   d       	                                                                   "                        	   �_    
                                                                                AreaProperties  AmbientSndDay   AmbientSndNight AmbientSndDayVolAmbientSndNitVolEnvAudio        MusicBattle     MusicDay        MusicNight      MusicDelay      Creature List   Door List       Encounter List  List            SoundList       StoreList       TriggerList     WaypointList    Placeable List                          	       
                                                               ITP V3.28   =     y   �      	       	  �  �
    ����                                                               (          0          8          @          H          P          X          `          h          p          x          �          �          �          �          �          �          �          �          �          �          �          �          �          �          �          �                                                         (         0         8         @         H         P         X         `         h         p         x         �         �         �         �         �         �         �         �         �         �         �         �                      %                 �         0         &        L         '                  (                  )                  *                  �          	         8                  9                  :                          d         G         "         H         #         I         $         J         %         1        x         2                  3                  4                  5                  6                                    �          2         ,        �         -         
         .                  �         1         8                  ;        �         <                  =                  >                  +         /         ?                  /                  #        �         
                  B                  �                   D                  C                  k                   E         !         K        �                   &                   '                   (                   *                   )         !          +         #          ,         �          -                                              !                  "                  #                  $                  L         .   MAIN            STRREF          LIST            ID                                      	   
                                                                      !   "   #   $   %   &   '   (   )   *   +   ,   -   .   /   0   1   2   3   4   5   6   7   8   9   :   ;   <   =   >   ?   @   A   B   C   D   E   F   G   H   I   J   K   L   M   N   O   P   Q   R   S   T   U   V   W   X   Y   Z   [   \   ]   ^   _   `   a   b   c   d   e   f   g   h   i   j   k   l   m   n   o   p   q   r   s   t   u   v   w   x         -   6   <            	   
                        $   %                                                                               !   "   #      &   '   (   )   *   +   ,      .   /   0   1   2   3   4   5      7   8   9   :   ;   ITP V3.28      �      �             X   t  8   ����                                                               (          0          8          @          H          P                                                            !                  "                  #                  $                  N                  O        (         P                  Q                  R            MAIN            STRREF          LIST            ID                                      	   
                                                                        	   
      ITP V3.28      �      �             X   t  4   ����                                                               (          0          8          @          H          P                       �                  �         	         �                  �                                                       !                  "                  #                  $                  �            MAIN            STRREF          ID              LIST                                    	   
                                                                        	   
   // Name     : hashset_nwnx
// Purpose  : A general purpose implementation combining a hash and a set (NWNX version)
// Author   : Ingmar Stieger
// Modified : December 18, 2003

// This file is licensed under the terms of the
// GNU GENERAL PUBLIC LICENSE (GPL) Version 2

/************************************/
/* Return codes                     */
/************************************/

int HASHSET_ERROR = FALSE;
int HASHSET_SUCCESS = TRUE;

/************************************/
/* Function prototypes              */
/************************************/

// create a new HashSet on oObject with name sHashSetName
// iSize is optional
int HashSetCreate(object oObject, string sHashSetName, int iSize = 500);

// Clear and delete sHashSetName on oObject
void HashSetDestroy(object oObject, string sHashSetName);

// return true if hashset sHashSet is valid
int HashSetValid(object oObject, string sHashSetName);

// return true if hashset sHashSet contains key sKey
int HashSetKeyExists(object oObject, string sHashSetName, string sKey);

// Set key sKey of sHashset to string sValue
int HashSetSetLocalString(object oObject, string sHashSetName, string sKey, string sValue);

// Retrieve string value of sKey in sHashset
string HashSetGetLocalString(object oObject, string sHashSetName, string sKey);

// Set key sKey of sHashset to integer iValue
int HashSetSetLocalInt(object oObject, string sHashSetName, string sKey, int iValue);

// Retrieve integer value of sKey in sHashset
int HashSetGetLocalInt(object oObject, string sHashSetName, string sKey);

// Delete sKey in sHashset
int HashSetDeleteVariable(object oObject, string sHashSetName, string sKey);

// Return the n-th key in sHashset
// note: this returns the KEY, not the value of the key;
string HashSetGetNthKey(object oObject, string sHashSetName, int i);

// Return the first key in sHashset
// note: this returns the KEY, not the value of the key;
string HashSetGetFirstKey(object oObject, string sHashSetName);

// Return the next key in sHashset
// note: this returns the KEY, not the value of the key;
string HashSetGetNextKey(object oObject, string sHashSetName);

// Return the current key in sHashset
// note: this returns the KEY, not the value of the key;
string HashSetGetCurrentKey(object oObject, string sHashSetName);

// Return the number of elements in sHashset
int HashSetGetSize(object oObject, string sHashSetName);

// Return TRUE if the current key is not the last one, FALSE otherwise
int HashSetHasNext(object oObject, string sHashSetName);

// public functions

int HashSetCreate(object oObject, string sHashSetName, int iSize = 500)
{
    SetLocalString(oObject, "NWNX!HASHSET!CREATE", sHashSetName + "!" + IntToString(iSize) + "!");
    return HASHSET_SUCCESS;
}

void HashSetDestroy(object oObject, string sHashSetName)
{
    SetLocalString(oObject, "NWNX!HASHSET!DESTROY", sHashSetName + "!!");
}

int HashSetValid(object oObject, string sHashSetName)
{
    SetLocalString(oObject, "NWNX!HASHSET!VALID", sHashSetName + "!!");
    return StringToInt(GetLocalString(oObject, "NWNX!HASHSET!VALID"));
}

int HashSetKeyExists(object oObject, string sHashSetName, string sKey)
{
    SetLocalString(oObject, "NWNX!HASHSET!EXISTS", sHashSetName + "!" + sKey + "!");
    return StringToInt(GetLocalString(oObject, "NWNX!HASHSET!EXISTS"));
}

int HashSetSetLocalString(object oObject, string sHashSetName, string sKey, string sValue)
{
    SetLocalString(oObject, "NWNX!HASHSET!INSERT", sHashSetName + "!" + sKey + "!" + sValue);
    return HASHSET_SUCCESS;
}

string HashSetGetLocalString(object oObject, string sHashSetName, string sKey)
{
    SetLocalString(oObject, "NWNX!HASHSET!LOOKUP", sHashSetName + "!" + sKey + "!                                                                                                                                          ");
    return GetLocalString(oObject, "NWNX!HASHSET!LOOKUP");
}

int HashSetSetLocalInt(object oObject, string sHashSetName, string sKey, int iValue)
{
    HashSetSetLocalString(oObject, sHashSetName, sKey, IntToString(iValue));
    return HASHSET_SUCCESS;
}

int HashSetGetLocalInt(object oObject, string sHashSetName, string sKey)
{
    string sValue = HashSetGetLocalString(oObject, sHashSetName, sKey);
    if (sValue == "")
        return 0;
    else
        return StringToInt(sValue);
}

int HashSetDeleteVariable(object oObject, string sHashSetName, string sKey)
{
    SetLocalString(oObject, "NWNX!HASHSET!DELETE", sHashSetName + "!" + sKey + "!");
    return HASHSET_SUCCESS;
}

string HashSetGetNthKey(object oObject, string sHashSetName, int i)
{
    SetLocalString(oObject, "NWNX!HASHSET!GETNTHKEY", sHashSetName + "!" + IntToString(i) + "!                                                                                                                                          ");
    return GetLocalString(oObject, "NWNX!HASHSET!GETNTHKEY");
}

string HashSetGetFirstKey(object oObject, string sHashSetName)
{
    SetLocalString(oObject, "NWNX!HASHSET!GETFIRSTKEY", sHashSetName + "!!                                                                                                                                          ");
    return GetLocalString(oObject, "NWNX!HASHSET!GETFIRSTKEY");
}

string HashSetGetNextKey(object oObject, string sHashSetName)
{
    SetLocalString(oObject, "NWNX!HASHSET!GETNEXTKEY", sHashSetName + "!!                                                                                                                                          ");
    return GetLocalString(oObject, "NWNX!HASHSET!GETNEXTKEY");
}

string HashSetGetCurrentKey(object oObject, string sHashSetName)
{
    SetLocalString(oObject, "NWNX!HASHSET!GETCURRENTKEY", sHashSetName + "!!                                                                                                                                          ");
    return GetLocalString(oObject, "NWNX!HASHSET!GETCURRENTKEY");
}

int HashSetGetSize(object oObject, string sHashSetName)
{
    SetLocalString(oObject, "NWNX!HASHSET!GETSIZE", sHashSetName + "!!           ");
    return StringToInt(GetLocalString(oObject, "NWNX!HASHSET!GETSIZE"));
}

int HashSetHasNext(object oObject, string sHashSetName)
{
    SetLocalString(oObject, "NWNX!HASHSET!HASNEXT", sHashSetName + "!!           ");
    return StringToInt(GetLocalString(oObject, "NWNX!HASHSET!HASNEXT"));
}

ITP V3.28   N   �  �   $     d      d  h  �  p  ����                                                               (          0          8          @          H          P          X          `          h          p          x          �          �          �          �          �          �          �          �          �          �          �          �          �          �          �          �                                                         (         0         8         @         H         P         X         `         h         p         x         �         �         �         �         �         �         �         �         �         �         �         �         �         �         �         �                                                        (         0         8         @         H         P         X         `                      O                  �                   �                  S         	         �                                    �         :         T        @         �                  U         
         V                  W        P         �         7         X                  �         ?         �         ;         �                  �         8         8        l         �         <         �         �         Y                  �                  Z                  [                  �                  �         9         ]        �         ^                  _                  \                  +                  a                  b                  �         6                 �                             !                  "                  #                  $                  L         5         �        �         d        �         e                  f                  g                  �                j                   h                  i                  k                l         !         m         "         n         #         o         $         +         %         p         &         �        4        q         '         r         (         s         )         t         *         �         =         w         .         x         /         y        L        z         0         {         1         |         2         �         3         �        \        v         +         �         ,         �         -         �         >         �         4   MAIN            STRREF          LIST            ID                                      	   
                                                                      !   "   #   $   %   &   '   (   )   *   +   ,   -   .   /   0   1   2   3   4   5   6   7   8   9   :   ;   <   =   >   ?   @   A   B   C   D   E   F   G   H   I   J   K   L   M   N   O   P   Q   R   S   T   U   V   W   X   Y   Z   [   \   ]   ^   _   `   a   b   c   d   e   f   g   h   i   j   k   l   m   n   o   p   q   r   s   t   u   v   w   x   y   z   {   |   }   ~      �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �               #   $   *   +                              	   
                                                 !   "                                 %   &   '   (   )   
   ,   0   4   ;   A   B   C   G   H   M      -   .   /      1   2   3      5   6   7   8   9   :      <   =   >   ?   @      D   E   F      I   J   K   L   NCS V1.0B  �          ����  ����   ����  ����*     +  ����    � 	myhashset  �     ���� myvalue mykey 	myhashset  �    O ���� mykey 	myhashset  �    �����  ���� result=���� # 0 	myhashset  �    	n    / hashset myhashset is valid 0    /-  hashset myhashset is not valid 0 myhashset111  �    �    2 hashset myhashset111 is valid 0    2-  !hashset myhashset111 is not valid 0 mykey 	myhashset  �    �    9 $hashset myhashset contains key mykey 0    =-  ,hashset myhashset does not contain key mykey 0 mykey111 	myhashset  �    _    < 'hashset myhashset contains key mykey111 0    @-  /hashset myhashset does not contain key mykey111 0 key loop 1: 0 myvalue2 mykey2 	myhashset  �    � ���� myvalue4 mykey4 	myhashset  �    f ���� myvalue6 mykey6 	myhashset  �    0 ���� myvalue8 mykey8 	myhashset  �    � ���� 	method 1: 0 	myhashset  �    ^����  ��������   #    } Key:���� # ; value:#����  	myhashset  �    �# 0 	myhashset  �    �����  ���� ���{ 	method 2: 0 	myhashset  �    �����  ��������  nomore#    � Key:���� # ; value:#����  	myhashset  �    # 0 	myhashset  �    (    4 	myhashset  �    �����  ����     -  nomore����  ���� ���5 key loop 2: 0 	myvalue16 mykey2 	myhashset  �    � ���� 	myvalue32 mykey4 	myhashset  �    � ���� mykey6 	myhashset  �    � ���� 	myhashset  �    �����  ��������   #    } Key:���� # ; value:#����  	myhashset  �    p# 0 	myhashset  �    }����  ���� ���{ Size of hashset:  	myhashset  �    @  \# 0    	myhashset  �    �����  ���� 3rd element key=���� # 0 	myhashset  �    v 	myhashset  �    �    E 0hashset myhashset is valid after call to destroy 0    E-  4hashset myhashset is not valid after call to destroy 0 ����  ����  !#����   \# !# NWNX!HASHSET!CREATE����   9'���� ����  ����     ���� ����  ����  !#���� # !#���� # NWNX!HASHSET!INSERT����   9'���� ����  ����     ���� ����  ����  !#���� # �!                                                                                                                                          # NWNX!HASHSET!LOOKUP����   9 NWNX!HASHSET!LOOKUP����   5����  ����     ���� ����  ����  !!# NWNX!HASHSET!VALID����   9 NWNX!HASHSET!VALID����   5  �����  ����     ���� ����  ����  !#���� # !# NWNX!HASHSET!EXISTS����   9 NWNX!HASHSET!EXISTS����   5  �����  ����     ���� ����  ����  �!!                                                                                                                                          # NWNX!HASHSET!GETFIRSTKEY����   9 NWNX!HASHSET!GETFIRSTKEY����   5����  ����     ���� ����  ����  �!!                                                                                                                                          # NWNX!HASHSET!GETNEXTKEY����   9 NWNX!HASHSET!GETNEXTKEY����   5����  ����     ���� ����  ����  !!           # NWNX!HASHSET!HASNEXT����   9 NWNX!HASHSET!HASNEXT����   5  �����  ����     ���� ����  ����  !#���� # !# NWNX!HASHSET!DELETE����   9'���� ����  ����     ���� ����  ����  !!           # NWNX!HASHSET!GETSIZE����   9 NWNX!HASHSET!GETSIZE����   5  �����  ����     ���� ����  ����  !#����   \# �!                                                                                                                                          # NWNX!HASHSET!GETNTHKEY����   9 NWNX!HASHSET!GETNTHKEY����   5����  ����     ���� ����  ����  !!# NWNX!HASHSET!DESTROY����   9 ����  NDB V1.0
0000003 0000001 0000039 0000044 0000088
n00 aps_include
n01 hashset_nwnx
N02 modload
s 03 vector
sf f x
sf f y
sf f z
f 00000757 00000869 000 v SQLInit
f ffffffff ffffffff 001 v SQLExecDirect
fp s
f ffffffff ffffffff 000 i SQLFetch
f ffffffff ffffffff 000 i SQLFirstRow
f ffffffff ffffffff 000 i SQLNextRow
f ffffffff ffffffff 001 s SQLGetData
fp i
f ffffffff ffffffff 001 s LocationToString
fp e2
f ffffffff ffffffff 001 e2 StringToLocation
fp s
f ffffffff ffffffff 001 s VectorToString
fp t0000
f ffffffff ffffffff 001 t0000 StringToVector
fp s
f ffffffff ffffffff 005 v SetPersistentString
fp o
fp s
fp s
fp i
fp s
f ffffffff ffffffff 005 v SetPersistentInt
fp o
fp s
fp i
fp i
fp s
f ffffffff ffffffff 005 v SetPersistentFloat
fp o
fp s
fp f
fp i
fp s
f ffffffff ffffffff 005 v SetPersistentLocation
fp o
fp s
fp e2
fp i
fp s
f ffffffff ffffffff 005 v SetPersistentVector
fp o
fp s
fp t0000
fp i
fp s
f ffffffff ffffffff 003 s GetPersistentString
fp o
fp s
fp s
f ffffffff ffffffff 003 i GetPersistentInt
fp o
fp s
fp s
f ffffffff ffffffff 003 f GetPersistentFloat
fp o
fp s
fp s
f ffffffff ffffffff 003 e2 GetPersistentLocation
fp o
fp s
fp s
f ffffffff ffffffff 003 t0000 GetPersistentVector
fp o
fp s
fp s
f ffffffff ffffffff 003 v DeletePersistentVariable
fp o
fp s
fp s
f ffffffff ffffffff 001 s SQLEncodeSpecialChars
fp s
f ffffffff ffffffff 001 s SQLDecodeSpecialChars
fp s
f 00000869 000008dc 003 i HashSetCreate
fp o
fp s
fp i
f 00000f1b 00000f58 002 v HashSetDestroy
fp o
fp s
f 00000a68 00000ae5 002 i HashSetValid
fp o
fp s
f 00000ae5 00000b74 003 i HashSetKeyExists
fp o
fp s
fp s
f 000008dc 00000954 004 i HashSetSetLocalString
fp o
fp s
fp s
fp s
f 00000954 00000a68 003 s HashSetGetLocalString
fp o
fp s
fp s
f ffffffff ffffffff 004 i HashSetSetLocalInt
fp o
fp s
fp s
fp i
f ffffffff ffffffff 003 i HashSetGetLocalInt
fp o
fp s
fp s
f 00000d8e 00000dfc 003 i HashSetDeleteVariable
fp o
fp s
fp s
f 00000dfc 00000f1b 003 s HashSetGetNthKey
fp o
fp s
fp i
f 00000b74 00000c82 002 s HashSetGetFirstKey
fp o
fp s
f 00000c82 00000d8e 002 s HashSetGetNextKey
fp o
fp s
f ffffffff ffffffff 002 s HashSetGetCurrentKey
fp o
fp s
f 0000007f 00000757 000 v main
f 0000000d 00000015 000 v #loader
f 00000015 0000007f 000 v #globals
v 00000017 ffffffff 00000000 i SQL_ERROR
v 0000002d ffffffff 00000004 i SQL_SUCCESS
v 00000043 ffffffff 00000008 i HASHSET_ERROR
v 00000059 ffffffff 0000000c i HASHSET_SUCCESS
v 000000e1 0000074f 00000000 s sResult
v 00000436 0000074f 00000004 s sKey
v 00000759 00000861 00000000 i i
v 0000075b 00000861 00000004 s sMemory
v 00000869 000008da 00000000 i #retval
v 00000869 000008d4 00000004 i iSize
v 00000869 000008d4 00000008 s sHashSetName
v 00000869 000008d4 0000000c o oObject
v 000008dc 00000952 00000000 i #retval
v 000008dc 0000094c 00000004 s sValue
v 000008dc 0000094c 00000008 s sKey
v 000008dc 0000094c 0000000c s sHashSetName
v 000008dc 0000094c 00000010 o oObject
v 00000954 00000a66 00000000 s #retval
v 00000954 00000a60 00000004 s sKey
v 00000954 00000a60 00000008 s sHashSetName
v 00000954 00000a60 0000000c o oObject
v 00000a68 00000ae3 00000000 i #retval
v 00000a68 00000add 00000004 s sHashSetName
v 00000a68 00000add 00000008 o oObject
v 00000ae5 00000b72 00000000 i #retval
v 00000ae5 00000b6c 00000004 s sKey
v 00000ae5 00000b6c 00000008 s sHashSetName
v 00000ae5 00000b6c 0000000c o oObject
v 00000b74 00000c80 00000000 s #retval
v 00000b74 00000c7a 00000004 s sHashSetName
v 00000b74 00000c7a 00000008 o oObject
v 00000c82 00000d8c 00000000 s #retval
v 00000c82 00000d86 00000004 s sHashSetName
v 00000c82 00000d86 00000008 o oObject
v 00000d8e 00000dfa 00000000 i #retval
v 00000d8e 00000df4 00000004 s sKey
v 00000d8e 00000df4 00000008 s sHashSetName
v 00000d8e 00000df4 0000000c o oObject
v 00000dfc 00000f19 00000000 s #retval
v 00000dfc 00000f13 00000004 i i
v 00000dfc 00000f13 00000008 s sHashSetName
v 00000dfc 00000f13 0000000c o oObject
v 00000f1b 00000f50 00000000 s sHashSetName
v 00000f1b 00000f50 00000004 o oObject
l00 0000013 00000015 0000002b
l00 0000014 0000002b 00000041
l01 0000013 00000041 00000057
l01 0000014 00000057 0000006d
l02 0000006 0000007f 00000085
l02 0000009 00000085 000000ab
l02 0000010 000000ab 000000df
l02 0000012 000000df 000000e1
l02 0000013 000000e1 00000112
l02 0000014 00000112 0000012c
l02 0000017 0000012c 00000146
l02 0000018 0000014c 0000016f
l02 0000019 00000175 00000177
l02 0000020 00000177 0000019e
l02 0000021 0000019e 000001bb
l02 0000022 000001c1 000001e7
l02 0000023 000001ed 000001ef
l02 0000024 000001ef 00000219
l02 0000027 00000219 0000023c
l02 0000028 00000242 0000026f
l02 0000029 00000275 00000277
l02 0000030 00000277 000002ac
l02 0000031 000002ac 000002d2
l02 0000032 000002d8 00000308
l02 0000033 0000030e 00000310
l02 0000034 00000310 00000348
l02 0000037 00000348 0000035c
l02 0000038 0000035c 00000392
l02 0000039 00000392 000003c8
l02 0000040 000003c8 000003fe
l02 0000041 000003fe 00000434
l02 0000043 00000434 00000436
l02 0000044 00000436 0000045e
l02 0000045 0000045e 00000472
l02 0000047 00000472 000004bb
l02 0000049 000004bb 000004e3
l02 0000053 000004e9 000004fd
l02 0000054 000004fd 00000534
l02 0000055 00000534 0000056b
l02 0000056 0000056b 00000595
l02 0000058 00000595 000005bd
l02 0000059 000005bd 000005d1
l02 0000061 000005d1 0000061a
l02 0000063 0000061a 00000642
l02 0000067 00000648 00000676
l02 0000068 00000676 00000699
l02 0000071 00000699 000006b1
l02 0000072 000006b1 000006cb
l02 0000073 000006d1 0000070a
l02 0000074 00000710 00000712
l02 0000075 00000712 0000074f
l02 0000076 00000755 00000757
l00 0000141 00000757 00000759
l00 0000144 00000759 0000075b
l00 0000146 0000075b 0000076f
l00 0000147 00000785 00000821
l00 0000146 00000821 00000835
l00 0000149 0000083b 00000861
l00 0000150 00000867 00000869
l01 0000068 00000869 000008b2
l01 0000069 000008b2 000008d4
l01 0000070 000008d4 000008dc
l01 0000091 000008dc 0000092a
l01 0000092 0000092a 0000094c
l01 0000093 0000094c 00000954
l01 0000097 00000954 00000a22
l01 0000098 00000a22 00000a60
l01 0000099 00000a60 00000a68
l01 0000079 00000a68 00000a9b
l01 0000080 00000a9b 00000add
l01 0000081 00000add 00000ae5
l01 0000085 00000ae5 00000b29
l01 0000086 00000b29 00000b6c
l01 0000087 00000b6c 00000b74
l01 0000130 00000b74 00000c37
l01 0000131 00000c37 00000c7a
l01 0000132 00000c7a 00000c82
l01 0000136 00000c82 00000d44
l01 0000137 00000d44 00000d86
l01 0000138 00000d86 00000d8e
l01 0000118 00000d8e 00000dd2
l01 0000119 00000dd2 00000df4
l01 0000120 00000df4 00000dfc
l01 0000124 00000dfc 00000ed2
l01 0000125 00000ed2 00000f13
l01 0000126 00000f13 00000f1b
l01 0000074 00000f1b 00000f50
l01 0000075 00000f50 00000f58
#include "hashset_nwnx"

void main()
{
    // Basic operations
    HashSetCreate(GetModule(), "myhashset");
    HashSetSetLocalString(GetModule(), "myhashset", "mykey", "myvalue");

    string sResult;
    sResult = HashSetGetLocalString(GetModule(), "myhashset", "mykey");
    WriteTimestampedLogEntry("result=" + sResult);

    // Test for validity
    if (HashSetValid(GetModule(), "myhashset"))
        WriteTimestampedLogEntry("hashset myhashset is valid");
    else
        WriteTimestampedLogEntry("hashset myhashset is not valid");
    if (HashSetValid(GetModule(), "myhashset111"))
        WriteTimestampedLogEntry("hashset myhashset111 is valid");
    else
        WriteTimestampedLogEntry("hashset myhashset111 is not valid");

    // Test for existance of key
    if (HashSetKeyExists(GetModule(), "myhashset", "mykey"))
        WriteTimestampedLogEntry("hashset myhashset contains key mykey");
    else
        WriteTimestampedLogEntry("hashset myhashset does not contain key mykey");
    if (HashSetKeyExists(GetModule(), "myhashset", "mykey111"))
        WriteTimestampedLogEntry("hashset myhashset contains key mykey111");
    else
        WriteTimestampedLogEntry("hashset myhashset does not contain key mykey111");

    // Enumeration test 1...
    WriteTimestampedLogEntry("key loop 1:");
    HashSetSetLocalString(GetModule(), "myhashset", "mykey2", "myvalue2");
    HashSetSetLocalString(GetModule(), "myhashset", "mykey4", "myvalue4");
    HashSetSetLocalString(GetModule(), "myhashset", "mykey6", "myvalue6");
    HashSetSetLocalString(GetModule(), "myhashset", "mykey8", "myvalue8");

    // Enumeration method 1
    WriteTimestampedLogEntry("method 1:");
    string sKey;
    sKey = HashSetGetFirstKey(GetModule(), "myhashset");
    while (sKey != "")
    {
        WriteTimestampedLogEntry("Key:" + sKey + "; value:" +
                                 HashSetGetLocalString(GetModule(), "myhashset", sKey));
        sKey = HashSetGetNextKey(GetModule(), "myhashset");
    }

    // Enumeration method 2
    WriteTimestampedLogEntry("method 2:");
    sKey = HashSetGetFirstKey(GetModule(), "myhashset");
    while (sKey != "nomore")
    {
        WriteTimestampedLogEntry("Key:" + sKey + "; value:" +
                                 HashSetGetLocalString(GetModule(), "myhashset", sKey));
        if (HashSetHasNext(GetModule(), "myhashset"))
            sKey = HashSetGetNextKey(GetModule(), "myhashset");
        else
            sKey = "nomore";
    }

    // Overwrite and delete values, run enumeration a second time
    WriteTimestampedLogEntry("key loop 2:");
    HashSetSetLocalString(GetModule(), "myhashset", "mykey2", "myvalue16");
    HashSetSetLocalString(GetModule(), "myhashset", "mykey4", "myvalue32");
    HashSetDeleteVariable(GetModule(), "myhashset", "mykey6");

    sKey = HashSetGetFirstKey(GetModule(), "myhashset");
    while (sKey != "")
    {
        WriteTimestampedLogEntry("Key:" + sKey + "; value:" +
                                 HashSetGetLocalString(GetModule(), "myhashset", sKey));
        sKey = HashSetGetNextKey(GetModule(), "myhashset");
    }

    // Show size of hashset
    WriteTimestampedLogEntry("Size of hashset: " + IntToString(HashSetGetSize(GetModule(), "myhashset")));

    // Indexed access of an element
    sResult = HashSetGetNthKey(GetModule(), "myhashset", 3);
    WriteTimestampedLogEntry("3rd element key=" + sResult);

    // Delete hashset and test for validity
    HashSetDestroy(GetModule(), "myhashset");
    if (HashSetValid(GetModule(), "myhashset"))
        WriteTimestampedLogEntry("hashset myhashset is valid after call to destroy");
    else
        WriteTimestampedLogEntry("hashset myhashset is not valid after call to destroy");
}
ITP V3.28      X  0   �     �      �  �   �  h   ����                                                               (          0          8          @          H          P          X          `          h          p          x          �          �          �          �          �          �          �                                         ~                  �                  8         	         �         
         �                  �                  �#                  �#                          8                             !                  "                  #                  $                  �                  �                 P         �                  �                                   ��                  <                 }            MAIN            STRREF          ID              LIST                                    	   
                                                                      !   "   #   $   %   &   '   (   )   *   +   ,   -   .   /                              	   
                                                FAC V3.28      p  M        �  5   �  4  �  l   ����<                                      $         0          D         P         \         h         t         �         �         �         �      	   �      
   �         �         �         �         �         �                                 (                      ����
                         ����
                        ����
                        ����
                        ����
      )                                                                           2                            2                            2                           d                                                                                                                                           d                           2                           d                                                       2                           d                           d                                                       2                           d                           d   FactionList     FactionParentID FactionName     FactionGlobal   RepList         FactionID1      FactionID2      FactionRep         PC   Hostile   Commoner   Merchant   Defender                        	   
                                                                          !   "   #   $   %   &   '   (   )   *   +   ,   -   .   /   0   1   2   3   4   5   6   7   8   9   :   ;   <   =   >   ?   @   A   B   C   D   E   F   G   H   I   J   K   L                                 	   
                                                ITP V3.28      �            @      @  `   �  8   ����                                                               (          0          8          @          H          P          X                       &                  9�                  �                  �                  �                                                        !                  "                  #                  $                  �            MAIN            STRREF          ID              LIST                                    	   
                                                                              	   
      ITP V3.28      �      L     �      �  8   �  $   ����                                                               (          0                       �                                                       !                  "                  #                  $            MAIN            STRREF          ID              LIST                                    	   
                                          ITP V3.28      �      l     �      �  x   $  H   ����                                                               (          0          8          @          H          P          X          `          h          p                       :                  �                  �#                                                       !                  "                  #                  $                  �        0         ��                  �                  �                  �                  ��            MAIN            STRREF          ID              LIST                                    	   
                                                                              
                  	                     ITP V3.28      �      L     �      �  8   �  $   ����                                                               (          0                                                            !                  "                  #                  $                  �            MAIN            STRREF          LIST            ID                                      	   
                                          IFO V3.28      P   1   �  1   �  �   J  �   
     ����    0      .                 
                                              
      8         B              
   	   N      
   R            B         B                            �?                                                                            \         
         Z         [         c         d         e         f         g          h      !   i      "   j      #   v      $   �      %   �      &   �      '   �      (   �      )   �      *   �      +         ,         -         .   �      /         0      Mod_ID          Mod_MinGameVer  Mod_Creator_ID  Mod_Version     Expansion_Pack  Mod_Name        Mod_Tag         Mod_Description Mod_IsSaveGame  Mod_CustomTlk   Mod_Entry_Area  Mod_Entry_X     Mod_Entry_Y     Mod_Entry_Z     Mod_Entry_Dir_X Mod_Entry_Dir_Y Mod_Expan_List  Mod_DawnHour    Mod_DuskHour    Mod_MinPerHour  Mod_StartMonth  Mod_StartDay    Mod_StartHour   Mod_StartYear   Mod_XPScale     Mod_OnHeartbeat Mod_OnModLoad   Mod_OnModStart  Mod_OnClientEntrMod_OnClientLeavMod_OnActvtItem Mod_OnAcquirItemMod_OnUsrDefinedMod_OnUnAqreItemMod_OnPlrDeath  Mod_OnPlrDying  Mod_OnPlrEqItm  Mod_OnPlrLvlUp  Mod_OnSpawnBtnDnMod_OnPlrRest   Mod_OnPlrUnEqItmMod_OnCutsnAbortMod_StartMovie  Mod_CutSceneListMod_GVar_List   Mod_Area_list   Area_Name       Mod_HakList     Mod_CacheNSSList   c��!�K��*����   1.0   ����       	   module000   MODULE   ����        area001 modload       nw_o0_deathnw_o0_dying  nw_o0_respawn    area001                            	   
                                                                      !   "   #   $   %   &   '   (   )   *   +   ,   -   /   0                             