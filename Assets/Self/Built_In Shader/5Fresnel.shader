Shader "Fresnel"
{
    Properties
    {
        _MainTex("_MainTex",2D) = "Bump"{}
        _MainSpeed("_MainSpeed",vector) = (0,0,0,0)
        _Scope("_Scope",Range(0,10)) = 5
        _Luminance("_Luminance",Range(0,10)) = 5
        _Intensidy("_Intensidy",Range(0,10)) = 5
        [HDR]_Color("_Color",Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" ="Transparent"  }
        Blend One One
        Cull Back
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST; 
            float2 _MainSpeed;
            half _Scope;
            half _Luminance;
            half _Intensidy;
            fixed4 _Color;


            struct appdata
            {
                float4 vert :POSITION;
                float2 uv : TEXCOORD;
                float3 normal : NORMAL;           
            };
            struct v2f
            {
                float4 pos :SV_POSITION;
                float2 uv  :TEXCOORD0;
                float3 worldPos :TEXCOORD1;
                float3 normal :TEXCOORD2;

            };

            v2f vert (appdata v) 
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vert);
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vert).xyz;
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }
            fixed4 frag(v2f i) :SV_TARGET
            {
                float2 uv_mainTex = i.uv * _MainTex_ST.xy + _MainTex_ST.zw;                
                float2 panner = (_Time.y * _MainSpeed + uv_mainTex);
                float4 _MainTex2D = tex2D(_MainTex,panner);

                float3 WorldView = UnityWorldSpaceViewDir(i.worldPos);

                float Dot = abs(1.0- dot(i.normal,normalize(WorldView)));
                float Power = saturate(pow(Dot,_Scope));
                float Multiply = Power * _Luminance;
                float Ad =  Multiply + _Intensidy;

                float4 Mulaph = _MainTex2D * Ad;
                float4 MulColor = Mulaph * _Color;
                return MulColor;
            }           
            
            ENDCG
        }
    }
}
