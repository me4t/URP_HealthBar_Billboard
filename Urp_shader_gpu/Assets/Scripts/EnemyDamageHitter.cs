using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using Random = UnityEngine.Random;

public class EnemyDamageHitter : MonoBehaviour
{
    [SerializeField] private float delayBetweenHit;
    [SerializeField] private float minHit;
    [SerializeField] private float maxHit;
    private Health[] _enemiesHealths;
    private WaitForSeconds _hitDelay;
    private const string EnemyTag = "Enemy";

    private void Awake()
    {
        _hitDelay = new WaitForSeconds(delayBetweenHit);
        CollectEnemies();
    }

    private void Start()
    {
        CreateHitCoroutine();
    }

    private void CreateHitCoroutine() => 
        StartCoroutine(Hit());

    private IEnumerator Hit()
    {
        while (!EnemiesIsDead())
        {
            yield return _hitDelay;
            Array.ForEach(_enemiesHealths,HitEnemy);
        }
    }

    private void HitEnemy(Health health)
    {
        float randomHit = Random.Range(minHit,maxHit);
        health.GetHit(randomHit);
    }

    private bool EnemiesIsDead() => 
        _enemiesHealths.All(x => !x.IsAlive());

    private void CollectEnemies()
    {
        var enemies = GameObject.FindGameObjectsWithTag(EnemyTag);
        List<Health> healths = new List<Health>();
        foreach (var enemy in enemies) 
            healths.Add(enemy.GetComponent<Health>());
        _enemiesHealths = healths.ToArray();
    }
}
