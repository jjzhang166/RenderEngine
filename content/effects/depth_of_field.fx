cbuffer CBufferPerRender {
	// x = focus distance
	// y = focus range
	// z = near clip
	// w = far clip / (near clip - far clip)
	float4 DoFParams;
	float2 ScreenResolution;
};

Texture2D ColorBuffer;
Texture2D BlurBuffer;
Texture2D DepthBuffer;

SamplerState LinearSampler;
SamplerState PointSampler {
	Filter = MIN_MAG_MIP_POINT;
};

float4 vertex_shader(float4 o_position : POSITION) : SV_Position {
	return o_position;
}

float4 pixel_shader(float4 p_position : SV_Position) : SV_Target {
	float2 uv = p_position.xy / ScreenResolution;

	float4 color_texel = ColorBuffer.Sample(LinearSampler, uv);
	float4 blur_texel = BlurBuffer.Sample(LinearSampler, uv);

	// NOTE we are in right-handed coordinate system
	// the value sampled has been normalized into [0, 1]
	// but the actual depth should be negtive
	float depth = -DepthBuffer.Sample(PointSampler, uv).r;

	// reverse depth into camera space
	float c_depth = (DoFParams.w * DoFParams.z) / (depth - DoFParams.w);

	// compute blur factor
	// note c_depth < 0
	float blur_factor = saturate(abs(c_depth + DoFParams.x) / DoFParams.y);

	// interpolate
	float4 color = float4(0, 0, 0, 0);
	color.rgb = lerp(color_texel, blur_texel, blur_factor).rgb;
	color.a = 1.0f;

	return color;
}

technique11 depth_of_field {
	pass p0 {
		SetVertexShader(CompileShader(vs_5_0, vertex_shader()));
		SetGeometryShader(NULL);
		SetPixelShader(CompileShader(ps_5_0, pixel_shader()));
	}
}