// 创建者:   Harling
// 创建时间: 2022-07-08 11:13:53
// 备注:     由PIToolKit工具生成

Shader "PIToolKit/UI/UGUI/BillBoard"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255
		_ColorMask ("Color Mask", Float) = 15
		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
		[Toggle(Parallel)] _Parallel("Parallel", Float)=0
	}

	CGINCLUDE
	#include "UnityCG.cginc"
	#include "UnityUI.cginc"
	#pragma multi_compile_instancing
	#pragma multi_compile _ Parallel

	sampler2D _MainTex;
	fixed4 _Color;
	fixed4 _TextureSampleAdd;
	float4 _ClipRect;

	struct appdata_t
	{
		float4 vertex   : POSITION;
		float4 color    : COLOR;
		float2 texcoord : TEXCOORD0;
		UNITY_VERTEX_INPUT_INSTANCE_ID
		UNITY_VERTEX_OUTPUT_STEREO
	};
	struct v2f
	{
		fixed4 color    : COLOR;
		float2 texcoord  : TEXCOORD0;
		float4 worldPosition : TEXCOORD1;
		UNITY_VERTEX_INPUT_INSTANCE_ID
		UNITY_VERTEX_OUTPUT_STEREO
	};
	
	void vert(appdata_t adt,out v2f o,out float4 pos:POSITION)
	{
		UNITY_SETUP_INSTANCE_ID(adt);
		UNITY_TRANSFER_INSTANCE_ID(adt, o);
		UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
		///广告版
		float3 normal=0;
		#ifdef Parallel
			normal = UNITY_MATRIX_V[2].xyz;
		#else
			normal = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1)).xyz;
			normal = normalize(normal);
		#endif
		float3 up = abs(normal.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
		float3 right = normalize(cross(normal, up));
		up = normalize(cross(right, normal));

		float3x3 m = { right, up, normal };
		m=transpose(m);
		adt.vertex.xyz=mul(m,adt.vertex.xyz);
		///
		o.worldPosition = adt.vertex;
		pos = UnityObjectToClipPos(o.worldPosition);
		o.texcoord = adt.texcoord;
		o.color = adt.color * _Color;
	}

	void frag(v2f data ,out fixed4 col:SV_Target)
	{
		UNITY_SETUP_INSTANCE_ID(data);
		col = (tex2D(_MainTex, data.texcoord) + _TextureSampleAdd) * data.color;
				
		col.a *= UnityGet2DClipping(data.worldPosition.xy, _ClipRect);
				
		#ifdef UNITY_UI_ALPHACLIP
		clip (col.a - 0.001);
		#endif
	}
	ENDCG

	SubShader
	{
		Tags
		{ 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}
		
		Stencil
		{
			Ref [_Stencil]
			Comp [_StencilComp]
			Pass [_StencilOp] 
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
		}

		Cull Off
		Lighting Off
		ZWrite Off
		ZTest [unity_GUIZTestMode]
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask [_ColorMask]

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			#pragma multi_compile __ UNITY_UI_ALPHACLIP
			ENDCG
		}
	}
}
