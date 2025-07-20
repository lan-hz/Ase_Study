Shader "Mask"
{
    Properties
    {
        _MainTex("_MainTex",2D) = "white"{}
        _MaskTex("_MaskTex",2D) = "white"{}
        [HDR]_ManiColor("_ManiColor",Color) = (1,1,1,1)
        _MainSpeed("_MainSpeed",vector) = (0,0,0,0)

    }
    SubShader
    {
        Tags{"RenderType" = "Transparent" "Queue" = "Transparent"}

        Blend one one       
        Cull Front

        pass
        {
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            
            sampler2D _MainTex;
            sampler2D _MaskTex;
            float4 _MainTex_ST;
            float4 _MaskTex_ST; 
            fixed4 _ManiColor;
            half2 _MainSpeed;

            struct appdata
            {
                float4 vertex : POSITION;    
                float2 uv : TEXCOORD;            
            };
            struct v2f
            {
                float4 pos :SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            } 
            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed4 Color;

                float2 uv_main = i.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                float2 uv_mask = i.uv * _MaskTex_ST.xy + _MaskTex_ST.zw;

                float2 pannerMain = _Time.y * _MainSpeed + uv_main;
                float2 pannerMask = _Time.y + uv_mask;




                float4 t = tex2D(_MainTex,pannerMain) * tex2D(_MaskTex,pannerMask) * _ManiColor;

                return t;
            }


            ENDCG
        }

    }
}