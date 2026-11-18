import { collection, getDocs } from 'firebase/firestore';
import { suite,matrix,actors,test,assertSucceeds,assertFails,now } from './helpers.mjs';
const s=suite();
const signed=actors.filter(a=>a!=='anonymous');
matrix(s,'config/app',{services:[]},{read:signed});
matrix(s,'config/unknown',{private:true},{read:['admin']});
matrix(s,'banners/demo',{title:'Offer',active:true,validUntil:now},{read:signed});
matrix(s,'banners/demo/private/secret',{internal:true},{});
for(const actor of actors)test('banner collection read '+actor,async()=>{
 await s.seed({'banners/demo':{title:'Offer'}});
 await (actor==='anonymous'?assertFails:assertSucceeds)(getDocs(collection(s.db(actor),'banners')));
});
