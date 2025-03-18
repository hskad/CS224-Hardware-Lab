#include<bits/stdc++.h>
#define ll long long
using namespace std;

// void solve() {
    
// }

int main() {
    ll x, dx, u, a;
    cin >> x >> dx >> u >> a;
    ll y = 0, u1, y1, x1;
    while (x < a) {
        u1 = u - (3*x*u*dx) - (3*y*dx);
        y1 = y + (u*dx);
        x1 = x + dx;
        x = x1, y = y1, u = u1;
        cout << y << endl;
    }

    

    // ios::sync_with_stdio(false);
    // cin.tie(nullptr);
    // ll t;
    // cin >> t;
    // while (t--) {
    //     solve();
    // }
}