Shader "Explorer/Mandelbrot"
{
    Properties
    {
        _MaxIterMandel("Iteration Mandel Max", Int) = 100
        _EyeIndex("EyeIndex", Range(0, 1)) = 0
    }
        SubShader
    {
        Tags {"Queue" = "Transparent" "RenderType" = "Transparent"}
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float Mandelbrot(float2 pos, float iterMax) {
                // Начальные значения для рисунка Мандельброта
                float2 z = float2(0.0, 0.0);
                float iter;

                // Вычисление рисунка Мандельброта
                for (iter = 0; iter < iterMax; iter++) {
                    z = float2(z.x * z.x - z.y * z.y, 2 * z.x * z.y) + pos;
                    if (length(z) > 2) break;
                }

                // Преобразуем результат в цвет
                float normalizedIter = iter / iterMax;
                return normalizedIter;
            }


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                uint eyeIndex : SV_RenderTargetArrayIndex;
            };

            int _MaxIterMandel;
            float _EyeIndex;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.eyeIndex = unity_StereoEyeIndex;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //Left eye
                if (i.eyeIndex == 0 && _EyeIndex >= 0.5f)
                {
                    return fixed4(0.0f, 0.0f, 0.0f, 1.0);
                }
                //Right eye
                else if(i.eyeIndex == 1 && _EyeIndex < 0.5f){
                    return fixed4(0.0f, 0.0f, 0.0f, 1.0);
                }

            // Нормализуем координаты пикселя
                float2 UV = i.uv *4.0 - 2.0;

                float result = Mandelbrot(UV, _MaxIterMandel);

                return fixed4(result, result, result, 1.0);
            }
            ENDCG
        }
    }
}
