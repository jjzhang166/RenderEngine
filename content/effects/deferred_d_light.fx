cbuffer CBufferPerRender {
	float2 ScreenResolution;
};

cbuffer CBufferPerFrame {
	float4 AmbientColor: AMBIENT;
	float4 LightColor: COLOR;
	float3 LightDirection: DIRECTION;
	float3 CameraPosition: CAMERAPOSITION;
};

Texture2D PositionBuffer;
Texture2D NormalBuffer;
Texture2D AlbedoSpecularBuffer;

RasterizerState DisableCulling {
	CullMode = NONE;
};

BlendState EnableAdditiveBlending {
	BlendEnable[0] = TRUE;
	SrcBlend = ONE;
	DestBlend = ONE;
};

DepthStencilState DisableDepth {
	DepthEnable = FALSE;
};

SamplerState TrilinearSampler {
	Filter = MIN_MAG_MIP_LINEAR;
};

float4 vertex_shader(float4 o_position : POSITION) : SV_Position {
	return o_position;
}

float4 pixel_shader(float4 p_position : SV_Position) : SV_Target {
	// convert from pixel position to texel position
	// http://www.asawicki.info/news_1516_half-pixel_offset_in_directx_11.html
	float2 uv = p_position.xy / ScreenResolution;

	float4 output = (float4)0;
	float3 w_pos = PositionBuffer.Sample(TrilinearSampler, uv).xyz;
	float4 normal = NormalBuffer.Sample(TrilinearSampler, uv);
	float SpecularPower = normal.w; // fetch specular power
	float4 texel = AlbedoSpecularBuffer.Sample(TrilinearSampler, uv);
	float3 albedo = texel.rgb;
	float specular = texel.a;
	specular = 0.8f;	// fix specular for test

	float3 light_dir = normalize(-LightDirection);
	float3 view_dir = normalize(CameraPosition - w_pos);
	float3 halfv = normalize(light_dir + view_dir);
	float n_dot_l = dot(normal.xyz, light_dir);
	float n_dot_h = dot(normal.xyz, halfv);

	float4 lambert_phong = lit(n_dot_l, n_dot_h, SpecularPower);

	float3 d = lambert_phong.y * (LightColor.rgb * LightColor.a) * albedo;
	// hard-coded specular color
	float4 SpecularColor = float4(1.0f, 1.0f, 1.0f, 1.0f);
	float3 s = min(lambert_phong.z, specular) * (SpecularColor.rgb * SpecularColor.a);
	float3 a = (AmbientColor.rgb * AmbientColor.a) * albedo;
	output.rgb = a + d + s;
	output.a = 1.0f;
	return output;
}

technique11 directional_light_pass {
	pass p0 {
		SetVertexShader(CompileShader(vs_5_0, vertex_shader()));
		SetGeometryShader(NULL);
		SetPixelShader(CompileShader(ps_5_0, pixel_shader()));
		SetRasterizerState(DisableCulling);
		SetDepthStencilState(DisableDepth, 0xFFFFFFFF);
		SetBlendState(EnableAdditiveBlending, float4(0.0f, 0.0f, 0.0f, 0.0f), 0xFFFFFFFF);
	}
}