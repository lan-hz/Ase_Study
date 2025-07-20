// 创建者:   Harling
// 创建时间: 2025-01-18 18:27:01
// 备注:     由PIToolKit工具生成

Shader "My project/Circle" 
{
	Properties 
	{
		_MainTex("MainTex",2D)="white"{}
		_Color("Color",color)=(1,1,1,1)
		MainRadius("MainRadius",range(0,0.5))=0.3
		MainSolidWidth("MainSolidWidth",range(0.01,0.1))=0.05
		MainFadeWidth("MainFadeWidth",range(0.01,0.1))=0.05
		MainArea("MainArea",vector) =(0,0,1,1)

		_SecondTex("SecondTex",2D)="white"{}
		SecondArea("SecondArea",vector) =(0.5,0.5,1,1)
	}

	CGINCLUDE
	#pragma target 4.0
	#pragma multi_compile_instancing
			
	#include "UnityCG.cginc"

	sampler2D _MainTex;
	float4 _MainTex_ST;
	float MainRadius;
	float MainSolidWidth;
	float MainFadeWidth;
	float4 MainArea;

	sampler2D _SecondTex;
	float4 SecondArea;
	UNITY_INSTANCING_BUFFER_START(Props)
	UNITY_DEFINE_INSTANCED_PROP(fixed4, _Color)
	UNITY_INSTANCING_BUFFER_END(Props)

	struct v2f
	{
		float2 UV:TEXCOORD0;
		float3 Normal:NORMAL0;
		UNITY_VERTEX_OUTPUT_STEREO
		UNITY_VERTEX_INPUT_INSTANCE_ID 
	};
	float InverseLerp(float min,float max,float value )
	{
		return (value-min)/(max-min);
	}

	void Vert(appdata_base adb,uint id:SV_INSTANCEID,uint vid : SV_VertexID,out v2f o,out float4 pos:POSITION)
	{
		UNITY_SETUP_INSTANCE_ID(adb);
		UNITY_TRANSFER_INSTANCE_ID(adb, o);
		UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				
		pos=UnityObjectToClipPos(adb.vertex);
		o.Normal=UnityObjectToWorldNormal(adb.normal);
		o.UV=adb.texcoord;
		o.UV=o.UV * _MainTex_ST.xy + _MainTex_ST.zw;
	}
	void FragForward(v2f data,out fixed4 col:SV_TARGET)
	{
		UNITY_SETUP_INSTANCE_ID(data);
		col=UNITY_ACCESS_INSTANCED_PROP(Props, _Color);

		//平面上任一点
		float2 p=data.UV;
		//半径
		float r=MainRadius;
		//圆心
		float2 o=float2(0.5,0.5);
		//点到圆边距离
		float d=abs(length(p-o)-r);
		//以灰度显示距离
		col.rgb=d;

		col.rgba=1;
		//计算发光衰减
		float max=MainFadeWidth+MainSolidWidth;
		float min=MainSolidWidth;
		float v=1-saturate(InverseLerp(min,max,d));
		col.a=v;

		//将贴图画到指定区域
		if(p.x>MainArea.x&&
			p.x<MainArea.z&&
			p.y>MainArea.y&&
			p.y<MainArea.w)
		{
			float2 mp=0;
			mp.x=saturate(InverseLerp(MainArea.x,MainArea.z,p.x));
			mp.y=saturate(InverseLerp(MainArea.y,MainArea.w,p.y));

			fixed4 mc=tex2D(_MainTex,mp);

			col.rgba=lerp(col.rgba,mc.rgba,mc.a);
		}

		if(p.x>SecondArea.x&&
			p.x<SecondArea.z&&
			p.y>SecondArea.y&&
			p.y<SecondArea.w)
		{
			float2 sp=0;
			sp.x=saturate(InverseLerp(SecondArea.x,SecondArea.z,p.x));
			sp.y=saturate(InverseLerp(SecondArea.y,SecondArea.w,p.y));

			fixed4 sc=tex2D(_SecondTex,sp);

			col.rgba=lerp(col.rgba,sc.rgba,sc.a);
		}
	}

	ENDCG

	SubShader 
	{
		Tags {"RenderType" = "Opaque" "Queue"="Geometry" "DisableBatching"="False"}
		pass
		{
			Tags {"LightMode" = "ForwardBase"}
			Name "FORWARD"
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Back
			ZWrite On
			ZTest LEqual
			Offset 0, 0
			ColorMask RGBA
			CGPROGRAM
			#pragma vertex Vert
			#pragma fragment FragForward
			ENDCG
		}
	}
}
