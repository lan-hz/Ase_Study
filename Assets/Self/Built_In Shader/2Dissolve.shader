Shader "Dissolve"
{
    Properties
    {
        _MainTex ("_MainTex", 2D) = "" {}
        _NoiseTex("_NoiseTex", 2D) = "" {}
        _Intensity("_Intensity",Range(0,1.05)) = 0
    }
    SubShader
    {
        Tags{"RenderType" = "Transparent" "Queue" = "Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha

        pass
        {
            Tags{"LightMode" = "ForwardBase"}

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag   

            sampler2D _MainTex; 
            float4  _MainTex_ST;
            sampler2D _NoiseTex; 
            float4  _NoiseTex_ST;
            float _Intensity;


            struct appdata
            {
                float4 vert : POSITION;
                float2 uv : TEXCOORD;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vert);
                o.uv = v.uv;
                return o;
            }
            fixed4 frag(v2f i) : SV_Target
            {
                //主图和扰动图的平铺和偏移
                float2 uv_mainTex = i.uv * _MainTex_ST.xy +  _MainTex_ST.zw;
                float2 uv_NoiseTex = i.uv * _NoiseTex_ST.xy +  _NoiseTex_ST.zw;
                //合图
                float4 MainTex2D = tex2D(_MainTex, uv_mainTex);
                float4 NoiseTex2D = tex2D(_NoiseTex, uv_NoiseTex);
                //溶解强度
                float noise = step(_Intensity,NoiseTex2D.r);
                //主图A通道和溶解相乘
                float Alp = (MainTex2D.a * noise);
                //合并数据
                float4 col = float4(MainTex2D.rgb , Alp);  

                return col; 
            }


            ENDCG
        }
        
    }
}
