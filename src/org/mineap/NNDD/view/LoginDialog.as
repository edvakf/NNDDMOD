/**
 * LoginDialog.as
 * 指定されたサイトへのログイン処理を行う。
 * 
 * Copyright (c) 2008 MAP - MineApplicationProject. All Rights Reserved.
 * 
 */
 
import flash.data.EncryptedLocalStore;
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.KeyboardEvent;
import flash.net.URLLoader;
import flash.ui.Keyboard;
import flash.utils.ByteArray;

import mx.controls.Alert;
import mx.controls.Button;
import mx.events.FlexEvent;

import org.mineap.NNDD.LogManager;
import org.mineap.NNDD.Message;
import org.mineap.util.config.ConfigManager;
import org.mineap.NNDD.view.LoadingPicture;
import org.mineap.nicovideo4as.Login;

public static const ON_LOGIN_SUCCESS:String = "onFirestTimeLoginSuccess";

public static const LOGIN_FAIL:String = "LoginFail";

public static const NO_LOGIN:String = "noLogin";

public static var TOP_PAGE_URL:String;
public static var LOGIN_URL:String;

public static var LABEL_CANCEL:String = "キャンセル";
public static var LABEL_LOGIN:String = "ログイン";
public static var LABEL_NO_LOGIN:String = "ログインしない";

private var userName:String;
private var password:String;
private var isStore:Boolean;
private var isAutoLogin:Boolean;
private var isLogout:Boolean;
private var logManager:LogManager;

//ログイン用URLローダー
private var _login:Login = null;

private var loading:LoadingPicture = new LoadingPicture();

public function initLoginDialog(topURL:String, loginURL:String, isStore:Boolean, isAutoLogin:Boolean, logManager:LogManager, userName:String = "", password:String = "", isLogout:Boolean = false):void
{
	TOP_PAGE_URL = topURL;
	LOGIN_URL = loginURL;
	loginButton.enabled = true;
	noLoginButton.enabled = true;
	
	this.logManager = logManager;
	this.isStore = isStore;
	this.isAutoLogin = isAutoLogin;
	this.isLogout = isLogout;
	this.userName = userName;
	this.password = password;
	
	this.addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteEventHandler);
	
	textInput_userName.setFocus();
}

public function creationCompleteEventHandler(event:Event):void{
	textInput_userName.text = this.userName;
	textInput_password.text = this.password;
	checkBox_storeUserNameAndPassword.selected = this.isStore;
	checkbox_autoLogin.selected = this.isAutoLogin;
	
	if(isAutoLogin && !isLogout){
		login();
	}
	
}

private function enterHandler(event:FlexEvent):void {
	
	if(textInput_userName.text.length >= 1 && textInput_password.text.length >= 1){
		login();
	}
	
}

// ログインボタン押下字の処理
private function login():void 
{
	if(loginButton.label == LoginDialog.LABEL_LOGIN){
		noLoginButton.enabled = false;
		loginButton.label = LoginDialog.LABEL_CANCEL;
	    
		var mailAddr:String = textInput_userName.text;
		var pass:String = textInput_password.text;
		
		if(_login != null){
			_login.close();
		}
		
	    _login = new Login();
		_login.addEventListener(Login.LOGIN_SUCCESS, loginSuccess);
		_login.addEventListener(Login.LOGIN_FAIL, loginFail);
		_login.login(mailAddr, pass);
		
	}else if(loginButton.label == LoginDialog.LABEL_CANCEL){
		noLoginButton.enabled = true;
		if(_login != null){
			try{
				_login.close();
			}catch(error:Error){
				
			}
		}
		loginButton.label = LoginDialog.LABEL_LOGIN;
	}
}

private function notLogin():void
{
	saveStore();
	
	loginButton.enabled = false;
	noLoginButton.enabled = false;
	loginButton.label = LoginDialog.LABEL_LOGIN;
    dispatchEvent(new HTTPStatusEvent(NO_LOGIN));
}

private function saveStore():void{
	var bytes:ByteArray = new ByteArray();
	
	if(checkBox_storeUserNameAndPassword.selected){
		
		setNameAndPass(textInput_userName.text, textInput_password.text);
		
		ConfigManager.getInstance().removeItem("storeNameAndPass");
		ConfigManager.getInstance().setItem("storeNameAndPass", true);
		
	}else{
		
		removeNameAndPass();
		
		ConfigManager.getInstance().removeItem("storeNameAndPass");
		ConfigManager.getInstance().setItem("storeNameAndPass", false);
		
	}
	
	ConfigManager.getInstance().removeItem("isAutoLogin");
	ConfigManager.getInstance().setItem("isAutoLogin", checkbox_autoLogin.selected);
	
	try{
		ConfigManager.getInstance().save();
	}catch(error:Error){
		trace(error.getStackTrace());
		Alert.show(Message.M_CONF_FILE_CAN_NOT_SAVE + "\n\n" + error, Message.M_ERROR);
	}
}

private function loginFail(event:ErrorEvent):void
{
	this._login.close();
	
	if(event.text != Login.LOGIN_FAIL_MESSAGE){
		
		Alert.show("ログインに失敗しました。\nインターネットに接続しているか確認してください。\n" + event.text, "エラー");	
		logManager.addLog("ログイン失敗:インターネットに接続していない:" + event);
		
	}else{
		
		Alert.show("ログインできません。\nメールアドレス、もしくはパスワードが間違っています。\n" + event.text,"エラー");
		logManager.addLog("ログイン失敗:メールアドレスもしくはパスワードの設定ミス:" + event);
	}
	
	loginButton.enabled = true;
	noLoginButton.enabled = true;
	loginButton.label = LoginDialog.LABEL_LOGIN;
	
	return;
}

private function removeNameAndPass():void{
	
	var temp:Error = null;
	try{
		EncryptedLocalStore.removeItem("userName");
	}catch(error:Error){
		trace(error.getStackTrace());
		temp = error;
	}
	try{
		EncryptedLocalStore.removeItem("password");
	}catch(error:Error){
		trace(error.getStackTrace());
		temp = error;
	}
	
	if(temp != null){
		var message:String = Message.M_CONF_FILE_CAN_NOT_SAVE + "\n" + temp;
		logManager.addLog(message);
		Alert.show(message, Message.M_ERROR);
	}
	
}

private function setNameAndPass(name:String, pass:String):void{
	var bytes:ByteArray = new ByteArray();
	var temp:Error = null;
	try{
		EncryptedLocalStore.removeItem("userName");
		bytes.writeUTFBytes(name);
		EncryptedLocalStore.setItem("userName", bytes);
	}catch(error:Error){
		trace(error.getStackTrace());
		temp = error;
	}
	try{
		EncryptedLocalStore.removeItem("password");
		bytes = new ByteArray();
		bytes.writeUTFBytes(pass);
		EncryptedLocalStore.setItem("password", bytes); 
	}catch(error:Error){
		trace(error.getStackTrace());
		temp = error;
	}
	
	if(temp != null){
		var message:String = Message.M_CONF_FILE_CAN_NOT_SAVE + "\n" + temp;
		logManager.addLog(message);
		Alert.show(message, Message.M_ERROR);
	}
}

	
private function loginSuccess(event:Event):void 
{	
	this._login.close();
	
	trace(event);
	saveStore();
	logManager.addLog("ログイン成功:" + event);
    
    // イベントを送出
    dispatchEvent(new HTTPStatusEvent(ON_LOGIN_SUCCESS));
}

private function buttonKeyUp(event:KeyboardEvent):void{
	if(event.keyCode == Keyboard.ENTER){
		if((event.target as Button).label == LoginDialog.LABEL_CANCEL){
			this.login();
		}else if((event.target as Button).label == LoginDialog.LABEL_LOGIN){
			this.login();
		}else if((event.target as Button).label == LoginDialog.LABEL_NO_LOGIN){
			this.notLogin();
		}
	}	
}