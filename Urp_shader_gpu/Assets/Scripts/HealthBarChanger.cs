using UnityEngine;

[RequireComponent(typeof(Health))]
public class HealthBarChanger: MonoBehaviour
{
    [SerializeField] private Health health;
    [SerializeField] private HealthBar healthBar;
    private void Awake()
    {
        health.Changed += ChangeBarValue;
    }
    private void OnDestroy()
    {
        health.Changed -= ChangeBarValue;
    }
    private void ChangeBarValue()
    {
        healthBar.UpdateParams(health.Current/health.Max);
    }
}