function Invoke-Request
{
	param (
		$parametros,
		$url
	)
	$bytes = [System.Text.Encoding]::ASCII.GetBytes($parametros)
	$ch = [System.Net.WebRequest]::Create($url)
	$ch.Method = "POST";
	$ch.ContentType = "application/x-www-form-urlencoded"
	$ch.ContentLength = $bytes.Length

	$stream = $ch.GetRequestStream()
	$stream.Write($bytes, 0, $bytes.Length)
	$stream.Flush()
	$stream.Close()
	$resp = $ch.GetResponse()
	$sr = [System.IO.StreamReader] $resp.GetResponseStream()
	$return = $sr.ReadToEnd().Trim()
	return $return
}
function Create-NewPaste
{
	param (
		[Parameter(Mandatory=$True)]
		$DevKey, # api_developer_key
		[Parameter(Mandatory=$True)]
		$PasteCode, # paste text
		[Int32]
		[ValidateSet(0, 1, 2)] # 0=public 1=unlisted 2=private
		$PastePrivacy = 1,
		[Parameter(Mandatory=$True)]
		$PasteName, # name or title of your paste
		[ValidateSet("N", "10M", "1H", "1D", "1M")]
		$PasteExpireDate = '10M',
		[Parameter(Mandatory=$False)]
		$PasteFormat, #paste format
		[Parameter(Mandatory=$False)]
		$UserKey = '' # if an invalid api_user_key or no key is used, the paste will be create as a guest
	)
	$api_dev_key 			= $DevKey;
	$api_paste_code 		= $PasteCode;
	$api_paste_private 		= $PastePrivacy;
	$api_paste_name			= $PasteName;
	$api_paste_expire_date  = $PasteExpireDate;
	$api_paste_format 		= $PasteFormat;
	$api_user_key 			= $UserKey;
	
	$api_paste_name			= [uri]::EscapeDataString($api_paste_name);
	$api_paste_code			= [uri]::EscapeDataString($api_paste_code);

	$url 				= 'http://pastebin.com/api/api_post.php';
	$parametros = "api_option=paste&api_user_key=$api_user_key&api_paste_private=$api_paste_private&api_paste_name=$api_paste_name&api_paste_expire_date=$api_paste_expire_date&api_paste_format=$api_paste_format&api_dev_key=$api_dev_key&api_paste_code=$api_paste_code"
	
	Invoke-Request $parametros $url
}

function Create-Api_User_Key
{
	param (
		[Parameter(Mandatory=$True)]
		$DevKey,
		[Parameter(Mandatory=$True)]
		$UserName,
		[Parameter(Mandatory=$True)]
		$UserPassword
	)
	$api_dev_key 			= $DevKey;
	$api_user_name 		= $UserName;
	$api_user_password 	= $UserPassword;
	
	$api_user_name 		= [uri]::EscapeDataString($api_user_name);
	$api_user_password 	= [uri]::EscapeDataString($api_user_password);
	
	$url			= 'http://pastebin.com/api/api_login.php';
	$parametros = "api_dev_key=$api_dev_key&api_user_name=$api_user_name&api_user_password=$api_user_password"

	Invoke-Request $parametros $url
}

function List-Pastes
{
	param (
		[Parameter(Mandatory=$True)]
		$DevKey,
		[Parameter(Mandatory=$True)]
		$UserKey,
		[Int32]
		[Parameter(Mandatory=$False)]
		$ResultsLimit = 50 # this is not required, by default its set to 50, min value is 1, max value is 1000
	)
	$api_dev_key 			= $DevKey;
	$api_user_key 		= $UserKey;
	$api_results_limit 	= $ResultsLimit;
	
	$url 			= 'http://pastebin.com/api/api_post.php';
	$parametros = "api_option=list&api_user_key=$api_user_key&api_dev_key=$api_dev_key&api_results_limit=$api_results_limit"
	
	Invoke-Request $parametros $url
}

function List-TrendingPastes
{
	param (
		[Parameter(Mandatory=$True)]
		$DevKey
	)
	$api_dev_key 		= $DevKey;
	
	$url 			= 'http://pastebin.com/api/api_post.php';
	$parametros = "api_option=trends&api_dev_key=$api_dev_key"
	
	Invoke-Request $parametros $url
}

function Delete-Paste
{
	param (
		[Parameter(Mandatory=$True)]
		$DevKey,
		[Parameter(Mandatory=$True)]
		$UserKey,
		[Parameter(Mandatory=$True)]
		$PasteKey
	)
	$api_dev_key 		= $DevKey;
	$api_user_key 		= $UserKey;
	$api_paste_key      = $PasteKey;
	
	$url 			= 'http://pastebin.com/api/api_post.php';
	$parametros = "api_option=delete&api_user_key=$api_user_key&api_dev_key=$api_dev_key&api_paste_key=$api_paste_key"
	
	Invoke-Request $parametros $url	
}

function Get-UserInformationAndSettings
{
	param (
		[Parameter(Mandatory=$True)]
		$DevKey,
		[Parameter(Mandatory=$True)]
		$UserKey
	)
	
	$api_dev_key 		= $DevKey;
	$api_user_key 		= $UserKey;
	
	$url 			= 'http://pastebin.com/api/api_post.php';
	$parametros = "api_option=userdetails&api_user_key=$api_user_key&api_dev_key=$api_dev_key"
	
	Invoke-Request $parametros $url
}

function Get-RawPasteOfUsers
{
	param (
		[Parameter(Mandatory=$True)]
		$DevKey,
		[Parameter(Mandatory=$True)]
		$UserKey,
		[Parameter(Mandatory=$True)]
		$PasteKey
	)
	$api_dev_key 		= $DevKey;
	$api_user_key 		= $UserKey;
	$api_paste_key      = $PasteKey;
	
	$url 			= 'http://pastebin.com/api/api_post.php';
	$parametros = "api_option=show_paste&api_user_key=$api_user_key&api_dev_key=$api_dev_key&api_paste_key=$api_paste_key"
	
	Invoke-Request $parametros $url
}

function Get-RawPaste
{
	Param (
		[Parameter(Mandatory=$True)]
		$PasteKey
	)
	$api_paste_key      = $PasteKey;
	$return = $(New-Object Net.WebClient).DownloadString("http://pastebin.com/raw/$api_paste_key")
	if ($return.Contains('AD-BLOCK DETECTED')) {
		return 'AD-BLOCK DETECTED';
	} else {
		return $return
	}
}