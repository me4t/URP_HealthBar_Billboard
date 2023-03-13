Shader "Unlit/HealthBar" {
    Properties {
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        _Health ("Health", Range(0,1)) = 1
        _BorderSize ("Border Size", Range(0,0.5)) = 0.1
    }
    SubShader {
        Tags{ "Queue" = "Overlay" "IgnoreProjector" = "True" "RenderType" = "Transparent" "DisableBatching" = "True" }

        Pass {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha // Alpha blending
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
            #pragma multi_compile_instancing
            #include "UnityCG.cginc"


            CBUFFER_START(_BorderSize)
			float _BorderSize;
			CBUFFER_END

            sampler2D _MainTex;

            UNITY_INSTANCING_BUFFER_START(Props)
            UNITY_DEFINE_INSTANCED_PROP(float, _Health)
            UNITY_INSTANCING_BUFFER_END(Props)
            float4 _MainTex_ST;


            float InverseLerp( float a, float b, float v )
            {
                return (v-a)/(b-a);
            }
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_FOG_COORDS(1)
			};

			v2f vert (appdata v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.uv = v.uv.xy;

				float4x4 modelVeiw = UNITY_MATRIX_M ;
				modelVeiw[0][0] = length(float3(unity_ObjectToWorld[0].x, unity_ObjectToWorld[1].x, unity_ObjectToWorld[2].x))   ; 
				modelVeiw[0][2] = 0 ; 

				modelVeiw[1][0] = 0 ; 
				modelVeiw[1][1] = length(float3(unity_ObjectToWorld[0].y, unity_ObjectToWorld[1].y, unity_ObjectToWorld[2].y)) ; 
				modelVeiw[1][2] = 0 ;

				modelVeiw[2][0] = 0 ; 
				modelVeiw[2][2] = 1 ;
				
				// billboard mesh towards camera
				float3 vpos = mul((float3x3)modelVeiw, v.vertex.xyz);
				float4 worldCoord = float4(unity_ObjectToWorld._m03, unity_ObjectToWorld._m13, unity_ObjectToWorld._m23, 1);
				float4 viewPos = mul(UNITY_MATRIX_V, worldCoord) + float4(vpos, 0);
				float4 outPos = mul(UNITY_MATRIX_P, viewPos);

				o.pos = outPos;
			
				UNITY_TRANSFER_FOG(o,o.pos);
				return o;
			}
            float4 frag (v2f i) : SV_Target {

            	UNITY_SETUP_INSTANCE_ID(i);

                float2 coords = i.uv;
                coords.x *= 8;
                float2 pointOnLineSeg = float2( clamp( coords.x, 0.5, 7.5 ), 0.5);
                float sdf = distance(coords, pointOnLineSeg) * 2 - 1;
                clip(-sdf);
            	
                float borderSdf = sdf + _BorderSize;
                float pd = fwidth(borderSdf); // screen space partial derivative
                float borderMask = 1-saturate(borderSdf / pd);

                float fill = UNITY_ACCESS_INSTANCED_PROP(Props, _Health);
                float healthbarMask = fill > i.uv.x;
                float3 healthbarColor = tex2D(_MainTex, float2(fill, i.uv.y));
            	
                if( fill < 0.2 )
                	{
                    float flash = cos( _Time.y * 4 ) * 0.4 + 1;
                    healthbarColor *= flash;
                }
				UNITY_APPLY_FOG(i.fogCoord, col);

                return float4( healthbarColor * healthbarMask * borderMask, 1 );
            }
            ENDCG
        }
    }
}
