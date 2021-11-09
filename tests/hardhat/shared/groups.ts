import { ethers } from 'ethers';

// const Box = '⬆︎';
// const Box2 = '░';
// const Box3 = '🀫';
// const Box4 = '♦︎';

const Box = '⬆︎';
const Box2 = '⬇︎';
const Box3 = '⇧';
const Box4 = '⇩';
const Reset = '\x1B[0m';
const Red = '\x1B[31m';
const Green = '\x1B[32m';
const Yellow = '\x1B[33m';
const Blue = '\x1B[34m';
const Purple = '\x1B[35m';
const Cyan = '\x1B[36m';
const Gray = '\x1B[37m';
const White = '\x1B[97m';

const colorLookup: { [_: number]: string } = [
    ' ',
    Green + Box + Reset,
    Yellow + Box + Reset,
    Blue + Box + Reset,
    Cyan + Box + Reset,
    Purple + Box + Reset,
    Gray + Box + Reset,
    Red + Box + Reset,
    White + Box + Reset,
    Green + Box2 + Reset,
    Yellow + Box2 + Reset,
    Blue + Box2 + Reset,
    Cyan + Box2 + Reset,
    Purple + Box2 + Reset,
    Gray + Box2 + Reset,
    Red + Box2 + Reset,
    White + Box2 + Reset,
    Green + Box3 + Reset,
    Yellow + Box3 + Reset,
    Blue + Box3 + Reset,
    Cyan + Box3 + Reset,
    Purple + Box3 + Reset,
    Gray + Box3 + Reset,
    Red + Box3 + Reset,
    White + Box3 + Reset,
    Green + Box4 + Reset,
    Yellow + Box4 + Reset,
    Blue + Box4 + Reset,
    Cyan + Box4 + Reset,
    Purple + Box4 + Reset,
    Gray + Box4 + Reset,
    Red + Box4 + Reset,
    White + Box4 + Reset,
];

type Group = {
    key: number;
    len: number;
};

function DecodeByteToGroup(a: number, b: number): Group {
    // if len(data) != 1 {
    // 	log.Fatal("trying to decode row not of length 2" + string(data))
    // }

    //  const [a, b] = toUint4(data);

    // fmt.Println(a, b+1)
    return {
        key: a,
        len: b + 1,
    };
}

function DecodeBytesToGroups(data: Uint8Array): Group[] {
    // if len(data) != 1 {
    // 	log.Fatal("trying to decode row not of length 2" + string(data))
    // }
    let res: Group[] = [];
    for (let i = 0; i < data.length; i += 2) {
        res.push(DecodeByteToGroup(data[i], data[i + 1]));
    }
    return res;
}

function toUint4(c: number): [number, number] {
    return [c >> 4, c & 0xf];
}

function EncodeToText(arr: Group[], width: number, height: number): string[] {
    let res: string[] = [];
    let i = 0;

    res.push(CreateNumberedRow(width));

    // for i := range arr {
    for (let y = 0; y < height; y++) {
        let tmp = '';
        // if y == int(d.Len.Y)-1 {
        // 	res.push("\n")
        // }
        for (let x = 0; x < width; x++) {
            // console.log(arr[i]);
            if (arr[i]) {
                tmp += colorLookup[arr[i].key] + colorLookup[arr[i].key];
                if (x + 1 < width) {
                    tmp += ' ';
                }
                arr[i].len--;
                if (arr[i].len == 0) {
                    i++;
                }
            } else {
                tmp += ' ';
            }
        }
        res.push(y.toString().padEnd(2) + ' ' + tmp + ' ' + y.toString().padStart(2));
    }

    res.push(CreateNumberedRow(width));

    return res;
}

function CreateNumberedRow(num: number): string {
    let res = '   ';
    for (var i = 0; i < num; i++) {
        res += (i % 10).toString() + '  ';
    }
    return res;
}

export const bashit = (input: string, width: number, height: number) => {
    const bytes = ethers.utils.base64.decode(input.replace('data:groups;base64,', ''));

    const groups = DecodeBytesToGroups(bytes);

    const output = EncodeToText(groups, width, height);
    output.forEach((x) => {
        console.log(x);
    });
};
