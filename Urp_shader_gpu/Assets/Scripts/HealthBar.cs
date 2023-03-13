using UnityEngine;

    public class HealthBar : MonoBehaviour
    {
        private const string ShaderPropertyHealth= "_Health";
        public  MeshRenderer meshRenderer;
        private MaterialPropertyBlock _blockProperty;
        private readonly int _health = Shader.PropertyToID(ShaderPropertyHealth);
        private void Awake()
        {
            _blockProperty = new MaterialPropertyBlock();
        }

        public void UpdateParams(float current)
        {
            meshRenderer.GetPropertyBlock(_blockProperty);
            _blockProperty.SetFloat(_health, current);
            meshRenderer.SetPropertyBlock(_blockProperty);
        }

        public void Activate()
        {
            gameObject.SetActive(true);
        }
        public void Disable()
        {
            gameObject.SetActive(false);
        }
    }
