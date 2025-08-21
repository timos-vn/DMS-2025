class LoginResponse {
	String? accessToken;
	String? refreshToken;
	LoginResponseUser? user;
	int? statusCode;
	String? message;

	LoginResponse(
			{this.accessToken,
				this.refreshToken,
				this.user,
				this.statusCode,
				this.message});

	LoginResponse.fromJson(Map<String, dynamic> json) {
		accessToken = json['accessToken'];
		refreshToken = json['refreshToken'];
		user = json['user'] != null ? new LoginResponseUser.fromJson(json['user']) : null;
		statusCode = json['statusCode'];
		message = json['message'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['accessToken'] = this.accessToken;
		data['refreshToken'] = this.refreshToken;
		if (this.user != null) {
			data['user'] = this.user!.toJson();
		}
		data['statusCode'] = this.statusCode;
		data['message'] = this.message;
		return data;
	}
}

class LoginResponseUser {
	int? userId;
	String? userName;
	String? hostId;
	int? code;
	String? codeName;
	int? role;
	String? phoneNumber;
	String? email;
	String? fullName;

	int? codeEmployeeSale;
	String? codeDepartment;
	String? nameDepartment;
	String? remainingDaysOff;
	int? nghiCL;

	LoginResponseUser(
			{this.userId,
				this.userName,
				this.hostId,
				this.code,
				this.codeName,
				this.role,
				this.phoneNumber,
				this.email,
				this.fullName,this.nghiCL});

	LoginResponseUser.fromJson(Map<String, dynamic> json) {
		userId = json['userId'];
		userName = json['userName'];
		hostId = json['hostId'];
		code = json['code'];
		codeName = json['codeName'];
		role = json['role'];
		phoneNumber = json['phoneNumber'];
		email = json['email'];
		fullName = json['fullName'];
		nghiCL = json['nghiCl'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['userId'] = this.userId;
		data['userName'] = this.userName;
		data['hostId'] = this.hostId;
		data['code'] = this.code;
		data['codeName'] = this.codeName;
		data['role'] = this.role;
		data['phoneNumber'] = this.phoneNumber;
		data['email'] = this.email;
		data['fullName'] = this.fullName;
		data['nghiCl'] = this.nghiCL;
		return data;
	}
}