use std::f64::consts::PI;

use rustler::{NifStruct, NifUnitEnum};

const TAU: f64 = 0.5;
const EPS: f64 = 1e-6;
const MU_OFFSET: f64 = 1500.0;
const GK_MAGIC: f64 = 173.7178;

#[derive(NifStruct, Clone)]
#[module = "Glicko"]
pub struct Glicko {
    pub mu: f64,
    pub phi: f64,
    pub sigma: f64,
}

trait Squarable {
    fn sqr(self) -> Self;
}

impl Squarable for f64 {
    fn sqr(self) -> Self {
        self * self
    }
}

#[derive(NifUnitEnum, Clone)]
pub enum MatchResult {
    Win,
    Loss,
    Draw,
}

#[derive(NifStruct, Clone)]
#[module = "Glicko.Match"]
pub struct Match {
    pub o: Glicko,
    pub r: MatchResult,
}

impl MatchResult {
    fn s(&self) -> f64 {
        match self {
            MatchResult::Win => 1.0,
            MatchResult::Draw => 0.5,
            MatchResult::Loss => 0.0,
        }
    }
}

impl Glicko {
    fn g(&self) -> f64 {
        // Step 3.pre-1
        (1.0 + 3.0 * self.phi.sqr() / PI.sqr()).sqrt().recip()
    }

    fn e(&self, o: &Glicko) -> f64 {
        // Step 3.pre-2
        (1.0 + (-o.g() * (self.mu - o.mu)).exp()).recip()
    }

    fn v(&self, os: &Vec<Glicko>) -> f64 {
        // Step 3
        os.into_iter()
            .map(|o| o.g().sqr() * self.e(&o) * (1.0 - self.e(&o)))
            .sum::<f64>()
            .recip()
    }

    fn d(&self, ms: &Vec<Match>) -> f64 {
        // Step 4
        ms.into_iter()
            .map(|m| m.o.g() * (m.r.s() - self.e(&m.o)))
            .sum()
    }

    fn f(&self, ms: &Vec<Match>, x: f64) -> f64 {
        // Step 5.1
        let os = ms.into_iter().map(|m| m.o.clone()).collect::<Vec<Glicko>>();

        let ex = x.exp();
        let num = ex * (self.d(&ms).sqr() - self.phi.sqr() - self.v(&os) - ex);
        let den = 2.0 * (self.phi.sqr() + self.v(&os) + ex).sqr();

        let a = self.sigma.sqr().ln();
        num / den - (x - a) / TAU.sqr()
    }

    fn sigmap(&self, ms: &Vec<Match>) -> f64 {
        // Step 5.2
        let os = ms.into_iter().map(|m| m.o.clone()).collect::<Vec<Glicko>>();
        let a = self.sigma.sqr().ln();
        let mut l = a;
        let mut r = if self.d(ms).sqr() > self.phi.sqr() + self.v(&os) {
            self.d(ms).sqr() - self.phi.sqr() - self.v(&os)
        } else {
            let mut k = TAU;
            while self.f(ms, a - k) < 0.0 {
                k -= TAU
            }
            a - k
        };

        // Step 5.3
        let mut fl = self.f(ms, l);
        let mut fr = self.f(ms, r);

        // Step 5.4
        while (r - l).abs() > EPS {
            let p = l + (l - r) * fl / (fr - fl);
            let fp = self.f(ms, p);
            if fp * fr < 0.0 {
                l = r;
                fl = fr;
            } else {
                fl = fl / 2.0
            }
            r = p;
            fr = fp;
        }
        // Step 5.5
        (l / 2.0).exp()
    }

    fn phip(&self, ms: &Vec<Match>) -> f64 {
        let os = ms.iter().map(|m| m.o.clone()).collect::<Vec<Glicko>>();
        let sphi = (self.phi.sqr() + self.sigmap(ms).sqr()).sqrt();
        (sphi.sqr().recip() + self.v(&os).recip()).sqrt().recip()
    }

    fn mup(&self, ms: &Vec<Match>) -> f64 {
        let fc = ms
            .into_iter()
            .map(|m| m.o.g() * (m.r.s() - self.e(&m.o)))
            .sum::<f64>();
        self.mu + self.phip(ms).sqr() * fc
    }

    fn update(&self, ms: &Vec<Match>) -> Glicko {
        if ms.is_empty() {
            Glicko {
                mu: self.mu,
                phi: (self.phi.sqr() + self.sigma.sqr()).sqrt(),
                sigma: self.sigma,
            }
        } else {
            Glicko {
                mu: self.mup(ms),
                phi: self.phip(ms),
                sigma: self.sigmap(ms),
            }
        }
    }
}

#[rustler::nif]
fn simple(r: f64, std: f64) -> Glicko {
    Glicko {
        mu: (r - MU_OFFSET) / GK_MAGIC,
        phi: std / GK_MAGIC,
        sigma: 0.06,
    }
}

#[rustler::nif]
fn update(g: Glicko, ms: Vec<Match>) -> Glicko {
    g.update(&ms)
}

#[rustler::nif]
fn rating(g: Glicko) -> f64 {
    g.mu * GK_MAGIC + MU_OFFSET
}

#[rustler::nif]
fn stdev(g: Glicko) -> f64 {
    g.phi * GK_MAGIC
}

rustler::init!("Elixir.Glicko", [simple, update, rating, stdev]);
