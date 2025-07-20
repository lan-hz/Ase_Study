// 创建者:   Harling
// 创建时间: 2024-03-21 15:34:46
// 备注:     由PIToolKit工具生成

Shader "ScadaUILibrary/DonutChart"
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
		_Width("CircalWidth",Range(0.01,0.5))=0.1
		_Radius("CircalRadius",Range(0.01,0.5))=0.45
		_Angle("Angle",Range(0,360))=180
		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
	}

	CGINCLUDE
	#include "UnityCG.cginc"
	#include "UnityUI.cginc"

	sampler2D _MainTex;
	fixed4 _Color;
	fixed4 _TextureSampleAdd;
	float4 _ClipRect;
	float _Width;
	float _Radius;
	float _Angle;

	struct appdata_t
	{
		float4 vertex   : POSITION;
		float4 color    : COLOR;
		float4 texcoord : TEXCOORD0;
		UNITY_VERTEX_INPUT_INSTANCE_ID
	};
	struct v2f
	{
		fixed4 color    : COLOR;
		float4 texcoord  : TEXCOORD0;
		float4 worldPosition : TEXCOORD1;
		UNITY_VERTEX_OUTPUT_STEREO
	};
	float Cross(float2 v1,float2 v2)
	{
		return v1.x*v2.y - v1.y * v2.x;
	}
	float Angle(float2 v1,float2 v2)
	{
		float dir=sign(Cross(v1,v2));
		float a=degrees(acos(dot(v1,v2)*dir));
		a+=saturate(-dir)*180;
		return a;
	}
	void RotateUV(inout float2 uv,float angle)
	{
		float s,c;
		sincos(radians(90-angle),s,c);
		float2x2 temp=float2x2(float2(s,c),float2(-c,s));
		uv= mul(temp,uv);
	}
	
	void vert(appdata_t adt,out v2f o,out float4 pos:POSITION)
	{
		UNITY_SETUP_INSTANCE_ID(adt);
		UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
		o.worldPosition = adt.vertex;
		pos = UnityObjectToClipPos(o.worldPosition);
		o.texcoord = adt.texcoord;
		o.color = adt.color * _Color;
	}

	void frag(v2f data ,out fixed4 col:SV_Target)
	{
		UNITY_SETUP_INSTANCE_ID(data);

		float2 uv=data.texcoord.xy;
		//解码外部传进来的值
		float _radius=data.texcoord.w;
		float _width=frac(data.texcoord.z);
		float _angle=((int)data.texcoord.z/100);
		//开始计算
		float2 zero=float2(0,_radius);
		float2 center=0.5;
		float2 offset=uv-center;
		//剪裁圆环区域
		float outter=(_radius+_width/2)-length(offset);
		float inner=(_radius-_width/2)-length(offset);
		clip(-outter*inner);
		float angle=Angle(normalize(offset),normalize(zero));
		float circle=_angle-angle;
		clip(circle);

		//剪裁端点区域
		if(_angle<360)
		{
			//计算起始点偏移的裁剪区域
			float hw=_width/2;
			float2 start=zero;
			float s=hw/_radius;
			float a=degrees(asin(s));
			RotateUV(start,a);
			start+=center;
			float d=length(uv-start);
			//裁剪起始端点
			clip((hw-d)*sign(angle<a));
			

			//计算终点偏移的裁剪区域
			float2 end=zero;
			a=_angle-a;
			RotateUV(end,a);
			end+=center;
			d=length(uv-end);
			//裁剪结束端点
			clip((hw-d)*sign(angle>a));
		}
		//修改环上的UV
		uv.x=angle/_angle; 
		RotateUV(zero,angle);
		zero+=center;
		uv.y=length(uv-zero);
		data.texcoord.xy=uv;

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
