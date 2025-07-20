// 创建者:   Harling
// 创建时间: 2022-12-09 11:04:01
// 备注:     由PIToolKit工具生成

Shader "The Lab/Effect/HoloGraphic" 
{
	Properties 
	{
		_MainTex("MainTex",2D)="white"{}
		_MainColor("MainColor",color)=(1,1,1,0.2)
		[HDR]_EdgeColor("EdgeColor",color)=(0,1,1,1)
		_Fresnel("Fresnel",Range(1,10))=5
		[KeywordEnum(None,XAxis,YAxis,ZAxis)]FlowMode("FlowMode",int)=0
		_Width("Width",Range(0,0.1))=0.003
		_Speed("Speed",Range(0,1))=0.1
		_Threshold("Threshold",Range(0,1))=0.95
	}

	CGINCLUDE
	#pragma target 4.0
	#pragma multi_compile_instancing
	#pragma multi_compile FLOWMODE_NONE FLOWMODE_XAXIS FLOWMODE_YAXIS FLOWMODE_ZAXIS		

	#include "UnityCG.cginc"

	#if FLOWMODE_XAXIS||FLOWMODE_YAXIS||FLOWMODE_ZAXIS
		#define NEEDFLOW
	#endif

	sampler2D _MainTex;
	float4 _MainTex_ST;
	half4 _MainColor;
	half4 _EdgeColor;
	float _Fresnel;
	float _Speed;
	float _Width;
	float _Threshold;

	struct v2f
	{
		float2 UV:TEXCOORD0;
		float3 WP:NORMAL0;
		float3 ViewVector:NORMAL1;
		float3 WorldNormal:NORMAL2;
		UNITY_VERTEX_OUTPUT_STEREO
		UNITY_VERTEX_INPUT_INSTANCE_ID 
	};
	
	void Vert(appdata_base adb,uint id:SV_INSTANCEID,out v2f o,out float4 pos:POSITION)
	{
		UNITY_SETUP_INSTANCE_ID(adb);
		UNITY_TRANSFER_INSTANCE_ID(adb, o);
		UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				
		pos=UnityObjectToClipPos(adb.vertex);
		o.UV=adb.texcoord;
		o.UV=o.UV * _MainTex_ST.xy + _MainTex_ST.zw;

		o.WP=mul(unity_ObjectToWorld,adb.vertex).xyz;
		o.WorldNormal=UnityObjectToWorldNormal(adb.normal);
		o.ViewVector=normalize(_WorldSpaceCameraPos.xyz -o.WP);
	}
	float RandomFloat(float v)
	{
		return frac(sin(v) * 43758.5453);
	}
	float InverseLerp(float min,float max,float value )
	{
		return (value-min)/(max-min);
	}
	float NotZerto(float3 v)
	{
		if(v.x!=0)return v.x;
		if(v.y!=0)return v.y;
		if(v.z!=0)return v.z;
		return 0;
	}
	void Frag(v2f data,out fixed4 col:SV_TARGET)
	{
		UNITY_SETUP_INSTANCE_ID(data);

		col=_MainColor;
		col*=tex2D(_MainTex,data.UV);

		float fresnel= 1-saturate(dot(data.WorldNormal,data.ViewVector));
		fresnel=pow(fresnel,_Fresnel);
		col=lerp(col,_EdgeColor,fresnel);

		#ifdef NEEDFLOW
			
			float3 dir=0;
			#if FLOWMODE_XAXIS
				dir=float3(1,0,0);
			#elif FLOWMODE_YAXIS
				dir=float3(0,1,0);
			#elif FLOWMODE_ZAXIS
			dir=float3(0,0,1);
			#endif

			float num=1/_Width;
			float speed=-_Time.y*_Speed;
			float seed=NotZerto(data.WP*dir)+speed;
			seed=floor(seed*num)+ceil(seed+num)/2/num;
			float bar=RandomFloat(seed+speed);
			bar=saturate(InverseLerp(_Threshold,1,bar));
			//bar=sign(saturate(bar-_Threshold))*bar;

			col=lerp(col,_EdgeColor,bar);
		#endif

		clip(col.a-0.01);
	}
	ENDCG

	SubShader 
	{
		Tags {"RenderType" = "Opaque" "Queue"="Transparent" "DisableBatching"="False"}
		pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Back
			ZWrite Off
			ZTest LEqual
			Offset 0, 0
			ColorMask RGBA
			CGPROGRAM
			#pragma vertex Vert
			#pragma fragment Frag
			ENDCG
		}
	}
}
