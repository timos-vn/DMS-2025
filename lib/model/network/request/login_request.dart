class LoginRequest {
	String? hostId;
	String? userName;
	String? password;
	String? devideToken;
	String? language;

	LoginRequest(
			{this.hostId,
				this.userName,
				this.password,
				this.devideToken,
				this.language});

	LoginRequest.fromJson(Map<String, dynamic> json) {
		hostId = json['hostId'];
		userName = json['userName'];
		password = json['password'];
		devideToken = json['devideToken'];
		language = json['language'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['hostId'] = this.hostId;
		data['userName'] = this.userName;
		data['password'] = this.password;
		data['devideToken'] = this.devideToken;
		data['language'] = this.language;
		return data;
	}
}