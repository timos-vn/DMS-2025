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
		user = json['user'] != null ? LoginResponseUser.fromJson(json['user']) : null;
		statusCode = json['statusCode'];
		message = json['message'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = <String, dynamic>{};
		data['accessToken'] = accessToken;
		data['refreshToken'] = refreshToken;
		if (user != null) {
			data['user'] = user!.toJson();
		}
		data['statusCode'] = statusCode;
		data['message'] = message;
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
	String? maNvbh;
	String? maNPP;
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
				this.maNvbh,
				this.maNPP,
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
		maNPP = json['maNPP'];
		maNvbh = json['maNvbh'];
		nghiCL = json['nghiCl'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = <String, dynamic>{};
		data['userId'] = userId;
		data['userName'] = userName;
		data['hostId'] = hostId;
		data['code'] = code;
		data['codeName'] = codeName;
		data['role'] = role;
		data['phoneNumber'] = phoneNumber;
		data['email'] = email;
		data['maNvbh'] = maNvbh;
		data['maNPP'] = maNPP;
		data['fullName'] = fullName;
		data['nghiCl'] = nghiCL;
		return data;
	}
}